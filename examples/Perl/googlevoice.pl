#!/usr/bin/perl
#
# Uses snowboy to wake up and then collect audio to send to Google Speech API for further recognition
# Takes Personal Model as a first argument

use lib 'Snowboy';

use Audio::PortAudio;
use Data::Dumper;
use Math::Round qw/round/;
use LWP::UserAgent;
use JSON;
use Statistics::Basic qw(:all);
use Time::HiRes qw(gettimeofday tv_interval);
use IO::Handle;

use Snowboy;

die "Usage: $0 <model.pmdl>" 
  if scalar @ARGV < 1;

STDOUT -> autoflush (1);
binmode STDOUT, ':utf8';

# Your choice of languages
use constant LANG => 'en';

# Audio format
use constant RATE => 16000;
use constant NUMCHANNELS   => 1;
use constant BITSPERSAMPLE => 16;

# Samples per data chunk count
use constant SAMPLES => 640;

# Detect 500ms silence (12 blocks * 40 ms = after 500ms of speech)
use constant TRAILING_SILENCE_BLOCKS => 12;

$models = '/var/spool/models';

use constant API_KEY => 'PUT_YOUR_GOOGLE_CLOUD_SPEECH_API_KEY_HERE';

# Google Speech API (language-dependent, set LANGUAGE channel var in the dialplan)
$url = "http://www.google.com/speech-api/v2/recognize?lang=" . LANG . "&key=" . API_KEY . "&output=json&maxresults=1&grammar=builtin:search";

my $api = Audio::PortAudio::default_host_api();

my $device = $api -> default_input_device;
   
my $stream = $device->open_read_stream (
  {channel_count => NUMCHANNELS, sample_format => 'int16'},
  RATE,
  SAMPLES);

print "Measuring silence...";

# Collect 1 sec worth of data and calculate silence treshold
for ($i = 0; $i < (1 / (SAMPLES / RATE)); $i++) {

  $stream -> read ($buffer, SAMPLES);

  # Discard first (noisy) block
  next if not $i;

  # Unpack into an array of 16-bit linear samples
  my $vec = vector (unpack ('s*', $buffer));

  my $stddev = round (stddev ($vec));
  my $mean = round (mean ($vec));

  push @alldevs, $stddev;
  push @allmeans, $mean;

  # printf "%.2f secs: mean: %d, stdddev: %d\n", $i * SAMPLES / RATE, $mean, $stddev;

  # Find AMX mean across all data chunks
  $maxdev = $stddev
   if $stddev > $maxdev;
}

my $vec = vector (@alldevs);
$stddev = round (stddev ($vec));
$mean = round (mean ($vec));

printf OUT "mean: %d, stdddev: %d, maxdev: %d\n", $mean, $stddev, $mean + $stddev;
$maxdev = $mean + $stddev;

# Too quiet (good silence supression, like SIP phones)
$maxdev = 100 if $maxdev < 100;

# Add margin to silence detection to be safe
$maxdev *= 2;

$dcoffset = round (mean (@allmeans));

# $dcoffset = 0;

print "OK (silence thold: $maxdev, DC offset: $dcoffset)\n";

$sb =  new Snowboy::SnowboyDetect ("$models/common.res", "$models/$ARGV[0]");

$sb -> SetSensitivity ('0.4');
$sb -> SetAudioGain (2.0);

# Test out the new model indefinitely, until the user hangs up
while (1) {

  $stream -> read ($buffer, SAMPLES);

  $processed = DSP ($buffer);

  $result = $sb -> RunDetection ($processed);

  $silence_blocks = 0;
  $speech_blocks  = 0;
  $prespeech = '';
  $speechbuffer  = '';

  if ($result == 1) {

    print 'Speak> ';

    $sb -> Reset ();

    while ($silence_blocks < TRAILING_SILENCE_BLOCKS) {

      $stream -> read ($buffer, SAMPLES);

      # Buffer up (trim the leading silence)
      $speechbuffer .= $buffer unless $speech_blocks < 5;

      if (is_silent ($buffer)) {

    	# Counts blocks of 20ms silence after solid 500ms of speech
        $silence_blocks++ unless $speech_blocks < 10;
      }
      else {
        $silence_blocks = 0;
        $speech_blocks++;
        $prespeech .= $buffer unless $speech_blocks >= 5;
        print '.';
      }
    }

    # print "\nSpeech collected, processing...\n";
    print "\n";

    $ua = LWP::UserAgent -> new (debug => 1);

    $t1 = [gettimeofday];
    my $response = $ua -> post ($url, Content_Type => "audio/l16; rate=" . RATE, Content => amp ($prespeech . $speechbuffer));
    $t2 = [gettimeofday];

    if ($response -> is_success) {

      # print $response -> content;

      my $resp = (split /\n/, $response -> content)[1];
      next if not $resp;

      $res = decode_json ($resp);

      # print Dumper ($res);
      $result = $res -> {result}[res -> {result_index}] -> {alternative}[0] -> {transcript}
    }
    else {
      delete $response->{'_request'}->{'_content'};
      # print Dumper($response);
    }

    # print "RECOGNIZED: $result\n";
    # print "TIMING: HTTP POST + GOOGLE SR: ", tv_interval ($t1, $t2);
    print "$result (", tv_interval ($t1, $t2), " sec)\n";
  }
}

sub DSP {
my $mysamples = shift;
my @processed, @samples;

  # Remove DC offset
  @samples = unpack ('s*', $mysamples);

  # Calculated DC offset for each voice data chunk
  # $mean = round (mean (@samples));

  # Use the same DC offset identified during training
  return pack ('s*', map {$_ -= $dcoffset} @samples);
}

sub is_silent {
my $samples = shift;

  # Unpack into an array of 16-bit linear samples
  my $vec = vector (unpack ('s*', $samples));
  my $stddev = round (stddev ($vec));

  $stddev < $maxdev ? print OUT "SILENCE\n" : print OUT "SPEECH\n";

  return $stddev < $maxdev;
}

sub amp {
my $samples = shift;

  return pack 's*', map {$_ <<= 3} unpack ('s*', $samples);
}
