#!/usr/bin/perl

# This script first uses Snowboy to wake up, then collects audio and sends to
# Google Speech API for further recognition. It works with both personal and
# universal models. By default, it uses the Snowboy universal model at
# resources/models/snowboy.umdl, you can change it to other universal models, or
# your own personal models. You also have to provide your Google API key in
# order to use it.

use Snowboy;

use Audio::PortAudio;
use Data::Dumper;
use Getopt::Long;
use IO::Handle;
use JSON;
use LWP::UserAgent;
use Statistics::Basic qw(:all);
use Time::HiRes qw(gettimeofday tv_interval);

my $Usage = <<EOU;

This script first uses Snowboy to wake up, then collects audio and sends to
Google Speech API for further recognition. It works with both personal and
universal models. By default, it uses the Snowboy universal model at
resources/models/snowboy.umdl, you can change it to other universal models, or
your own personal models. You also have to provide your Google API key in order
to use it.

Note: Google is now moving to Google Cloud Speech API, so we will have to update
      the API query later.

Usage: ./snowboy_googlevoice.pl <Google_API_Key> [Hotword_Model]
 e.g.: ./snowboy_googlevoice.pl \
           abcdefghijklmnopqrstuvwxyzABC0123456789 resources/models/snowboy.umdl

Allowed options:
  --language    : Language for speech recognizer.   (string, default="en")

EOU

my $language = "en";
GetOptions('language=s' =>  \$language);

if (@ARGV < 1 || @ARGV > 2) {
  die $Usage;
}

# Gets parameters.
my $api_key = shift @ARGV;
my $model = shift @ARGV || 'resources/models/snowboy.umdl';

if ($model eq 'resources/models/snowboy.umdl') {
  $hotword = "Snowboy";
} else {
  $hotword = "your hotword";
}

# Output setting.
STDOUT->autoflush(1);
binmode STDOUT, ':utf8';

# Audio format.
use constant RATE => 16000;
use constant NUMCHANNELS   => 1;
use constant BITSPERSAMPLE => 16;

# Samples per data chunk count
use constant SAMPLES => 640;

# Detects 500ms silence (12 blocks * 40 ms = after 500ms of speech)
use constant TRAILING_SILENCE_BLOCKS => 12;

# Google Speech API endpoint (language-dependent).
$url = "http://www.google.com/speech-api/v2/recognize?lang="
       . $language
       . "&key="
       . $api_key
       . "&output=json&maxresults=1&grammar=builtin:search";

# Audio capturing.
my $api = Audio::PortAudio::default_host_api();
my $device = $api->default_input_device;
my $stream = $device->open_read_stream(
  {channel_count => NUMCHANNELS, sample_format => 'int16'},
  RATE,
  SAMPLES);

# Collects 1000 msec worth of voice data and calculates silence treshold and DC
# offset.
print "\n";
print "Calculating statistics on silence, please be quite...\n";
for ($i = 0; $i < (1 / (SAMPLES / RATE)); $i++) {
  # SLN format = 2 bytes per sample.
  $stream->read($buffer, SAMPLES);

  # Discards first (usually noisy) block.
  next if not $i;

  # Unpacks into an array of 16-bit linear samples.
  my $vec = vector(unpack('s*', $buffer));

  my $stddev = round(stddev($vec));
  my $mean = round(mean($vec));

  push @alldevs, $stddev;
  push @allmeans, $mean;

  # printf "%.2f secs: mean: %d, stdddev: %d\n",
  # $i * SAMPLES / RATE, $mean, $stddev;

  # Find AMX mean across all data chunks.
  $maxdev = $stddev if $stddev > $maxdev;
}

my $vec = vector(@alldevs);
$stddev = round(stddev($vec));
$mean = round(mean($vec));

$maxdev = $mean + $stddev;

# Too quiet (good silence supression, like SIP phones)
$maxdev = 100 if $maxdev < 100;

# Add margin to silence detection to be safe.
$maxdev *= 2;

$dcoffset = round(mean(@allmeans));

print "Done (Silence Threshold: $maxdev, DC Offset: $dcoffset)\n";

# Snowboy decoder.
$sb = new Snowboy::SnowboyDetect('resources/common.res', $model);
$sb->SetSensitivity('0.5');
$sb->SetAudioGain(1.0);
$sb->ApplyFrontend(0);

# Running the detection forever.
print "\n";
print "Start by saying " . $hotword . "...\n";
while (1) {
  $stream->read($buffer, SAMPLES);
  $processed = DSP($buffer);

  # Running the Snowboy detection.
  $result = $sb->RunDetection($processed);

  $silence_blocks = 0;
  $speech_blocks  = 0;
  $prespeech = '';
  $speechbuffer  = '';

  if ($result == 1) {
    print 'Speak> ';
    $sb->Reset();

    while ($silence_blocks < TRAILING_SILENCE_BLOCKS) {
      $stream->read($buffer, SAMPLES);

      # Buffer up (trim the leading silence).
      $speechbuffer .= $buffer unless $speech_blocks < 5;

      if (isSilence($buffer)) {
    	  # Counts blocks of 20ms silence after solid 500ms of speech.
        $silence_blocks++ unless $speech_blocks < 10;
      } else {
        $silence_blocks = 0;
        $speech_blocks++;
        $prespeech .= $buffer unless $speech_blocks >= 5;
        print '.';
      }
    }

    print "\n";

    $ua = LWP::UserAgent->new(debug => 1);
    $t1 = [gettimeofday];
    my $response = $ua->post(
        $url,
        Content_Type => "audio/l16; rate=" . RATE,
        Content => amp($prespeech . $speechbuffer));
    $t2 = [gettimeofday];

    if ($response->is_success) {
      my $resp = (split /\n/, $response->content)[1];
      next if not $resp;
      $res = decode_json($resp);

      $result = $res->{result}[res->{result_index}]
          ->{alternative}[0]->{transcript};
    } else {
      delete $response->{'_request'}->{'_content'};
      print "Failed to do speech recognition from Google Speech API:\n";
      die $response->status_line;
    }

    print "$result (", tv_interval ($t1, $t2), " sec)\n";
    print "\n";
    print "Start by saying " . $hotword . "...\n";
  }
}

sub DSP {
  my $mysamples = shift;
  my @processed, @samples;

  # Removes DC offset.
  @samples = unpack('s*', $mysamples);

  # Calculated DC offset for each voice data chunk.
  # $mean = round(mean(@samples));

  # Uses the same DC offset identified during training.
  return pack('s*', map {$_ -= $dcoffset} @samples);
}

sub isSilence {
  my $samples = shift;

  # Unpacks into an array of 16-bit linear samples.
  my $vec = vector(unpack('s*', $samples));
  my $stddev = round(stddev($vec));

  return $stddev < $maxdev;
}

sub amp {
  my $samples = shift;
  return pack 's*', map {$_ <<= 3} unpack('s*', $samples);
}

sub round {
  my($number) = shift;
  return int($number + .5);
}
