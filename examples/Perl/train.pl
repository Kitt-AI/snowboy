#!/usr/bin/perl

use Audio::PortAudio;
use Math::Round qw/round/;
use LWP::UserAgent;
use IO::Handle;
use JSON;
use Statistics::Basic qw(:all);
use IO::Handle;
use MIME::Base64;
use File::Path qw(make_path);

$|++;

# Audio format
use constant RATE => 16000;
use constant NUMCHANNELS   => 1;
use constant BITSPERSAMPLE => 16;

# Calculate number of samples per chunk based on a given chunk size in milliseconds
use constant CHUNK_SIZE_MS => 20;
use constant SAMPLES => RATE * CHUNK_SIZE_MS / 1000;

# Miniumum number of non-silent chunks to count as utterance. Anything less is noise
use constant MIN_SPEECH => 5;

# Detect 500ms silence (25 blocks * 20 ms ~500ms of speech) before termiating recording
use constant TRAILING_SILENCE_BLOCKS => 25;

# Depth of FIFO buffer in blocks
use constant FIFO_DEPTH => 25;

use constant LANG => 'en';

# KITT AI API
use constant APITOKEN => 'PUT_YOUR_TOKEN_HERE';

# REST endpoint for model training
use constant URL => 'https://snowboy.kitt.ai/api/v1/train/';

# Storage for generated models / samples
$models = '/var/spool/models';

$trailing_silence_blocks = 0;
$speech_blocks = 0;
$buffer = '';

my $api = Audio::PortAudio::default_host_api();

my $device = $api -> default_input_device;

my $stream = $device -> open_read_stream (
  {channel_count => NUMCHANNELS, sample_format => 'int16'},
  RATE,
  SAMPLES);

# Collect 1000 msec worth of voice data and calculate silence treshold and DC offset
for ($i = 0; $i < (1000 / CHUNK_SIZE_MS); $i++) {

  # SLN format = 2 bytes per sample
  $stream -> read ($buffer, SAMPLES);

  # Discard first (noisy) block
  next if not $i;

  # Unpack into an array of 16-bit linear samples
  my $vec = vector (unpack ('s*', $buffer));

  my $stddev = round (stddev ($vec));
  my $mean = round (mean ($vec));

  push @alldevs, $stddev;
  push @allmeans, $mean;

  printf "%.2f secs: mean: %d, stdddev: %d\r", $i * SAMPLES / RATE, $mean, $stddev;

  # Find MAX mean across all data chunks
  $maxdev = $stddev
   if $stddev > $maxdev;
}

my $vec = vector (@alldevs);
$stddev = round (stddev ($vec));
$mean = round (mean ($vec));

# printf "mean: %d, stddev: %d, range: %d-%d\n", $mean, $stddev, $mean - $stddev, $mean + $stddev;
$maxdev = $mean + $stddev;

# Too quiet (good silence supression, like SIP phones)
$maxdev = 100 if $maxdev < 100;

# Add margin to silence detection to be safe
$maxdev *= 2;

$dcoffset = round (mean (@allmeans));

print "Silence thold: $maxdev, DC Offset: $dcoffset\n";

@spin = (qw[/ - \ |]);

# Collect 3 voice samples to send to KITT.AI for personal model generation
for ($samples = 0; $samples < 3; $samples++) {

  $speech_blocks = 0;
  $trailing_silence_blocks = 0;
  @utterance_blocks = ();
  $buffer = ''; $i = 0;

  while ($trailing_silence_blocks < TRAILING_SILENCE_BLOCKS) {

    $stream -> read ($buffer, SAMPLES);

    push @utterance_blocks, $buffer;

    if (is_silent ($buffer)) {

      
      if ($speech_blocks > MIN_SPEECH) {
        print '.';
        $trailing_silence_blocks++;
      }
      else { # No good speech collected; restart

        print $spin[$i++], "\r";
        $i = 0 if $i == scalar @spin;

        $speech_blocks = 0;

        shift @utterance_blocks
          if scalar @utterance_blocks > FIFO_DEPTH;  # FIFO - remove first block, shift array up
      }
    }
    else {
      print '*' if $speech_blocks > MIN_SPEECH;
      $speech_blocks++;
      $trailing_silence_blocks = 0;
    }
  }

  printf "\nUtterance is %.2f seconds long (%d blocks)\n", 20 * (scalar @utterance_blocks) / 1000, scalar @utterance_blocks;

  $utterance[$samples] = join '', @utterance_blocks;
}

# Unique name for each model
$model = 'MODEL_' . time;

# Send API request to KITT.AI
$APIreq = encode_json ({
  #  gender     => 'male',
  #  age_group  => '40-49',
  name       => $model,
  language   => LANG,
  token      => APITOKEN,
  microphone => 'mobiile',
  voice_samples => [
    {wave => encode_base64 (addWavHeader ($utterance[0]))},
    {wave => encode_base64 (addWavHeader ($utterance[1]))},
    {wave => encode_base64 (addWavHeader ($utterance[2]))}
  ]
});

$ua = LWP::UserAgent -> new (debug => 1);
my $response = $ua -> post (URL, Content_Type => "application/json", Content => $APIreq);

if ($response -> is_success) {

  make_path ("$models/$model");

  # Store samples
  for (0..2) {
    my $fh = IO::File -> new ("> $models/$model/sample$_.wav");
    if (defined $fh) {
      print $fh addWavHeader($utterance[$_]);
      $fh -> close;
    }
  }

  # Store generated personal model
  my $fh = IO::File -> new ("> $models/$model/model.pmdl");
  if (defined $fh) {
    print $fh $response->content;
    $fh -> close;
  }

  print "Model $model created OK\n";

}
else {
  die 'Can\'t create model: ', $response -> status_line;
}

sub is_silent {
my $samples = shift;

  # Unpack into an array of 16-bit linear samples
  my $vec = vector (unpack ('s*', $samples));
  my $stddev = round (stddev ($vec));

  return $stddev < $maxdev;
}

# WAV format reference
# http://soundfile.sapp.org/doc/WaveFormat/
#
sub addWavHeader {
my $raw = shift;
my $header;

  my $byterate = RATE * NUMCHANNELS * BITSPERSAMPLE / 8;
  my $blockalign = NUMCHANNELS * BITSPERSAMPLE / 8;

  $header = pack ('A4VA4A4VvvVVvvA4V',
    'RIFF',
    36 + length $raw,
    'WAVE',
    'fmt',
    16,
    1, # PCM
    1, # Num Channels
    RATE,
    $byterate,
    $blockalign,
    BITSPERSAMPLE,
    'data',
    length $raw
  );

  return $header . $raw;
}
