#!/usr/bin/perl

# This script uses PortAudio to record 3 audio samples on your computer, and
# sends them to the KITT.AI RESTful API to train the personal hotword model.

use Audio::PortAudio;
use File::Path qw(make_path);
use IO::Handle;
use JSON;
use LWP::UserAgent;
use MIME::Base64;
use Statistics::Basic qw(:all);

my $Usage = <<EOU;

This script uses PortAudio to record 3 audio samples on your computer, and sends
them to the KITT.AI RESTful API to train the personal hotword model.

Usage: ./snowboy_RESTful_train.pl <API_TOKEN> <Hotword> <Language>
 e.g.: ./snowboy_RESTful_train.pl \
           abcdefghijklmnopqrstuvwxyzABCD0123456789 snowboy en

EOU

if (@ARGV != 3) {
  die $Usage;
}

# Gets parameters.
my $api_token = shift @ARGV;
my $hotword = shift @ARGV;
my $language = shift @ARGV;

# Turns on OUTPUT_AUTOFLUSH.
$|++;

# Audio format
use constant RATE => 16000;
use constant NUMCHANNELS   => 1;
use constant BITSPERSAMPLE => 16;

# Calculates number of samples per chunk based on a given chunk size in
# milliseconds.
use constant CHUNK_SIZE_MS => 20;
use constant SAMPLES => RATE * CHUNK_SIZE_MS / 1000;

# Miniumum number of non-silent chunks to count as utterance. Anything less is
# noise.
use constant MIN_SPEECH => 5;

# Detects 500ms silence (25 blocks * 20 ms ~500ms of speech) before termiating
# recording.
use constant TRAILING_SILENCE_BLOCKS => 25;

# Depth of FIFO buffer in blocks
use constant FIFO_DEPTH => 25;

# REST endpoint for model training
use constant URL => 'https://snowboy.kitt.ai/api/v1/train/';

$trailing_silence_blocks = 0;
$speech_blocks = 0;
$buffer = '';

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
for ($i = 0; $i < (1000 / CHUNK_SIZE_MS); $i++) {
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

  # printf "%.2f secs: mean: %d, stdddev: %d\r",
  #     $i * SAMPLES / RATE, $mean, $stddev;

  # Finds MAX mean across all data chunks.
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

@spin = (qw[/ - \ |]);

# Collects 3 voice samples to send to KITT.AI for personal model training.
for ($samples = 0; $samples < 3; $samples++) {
  $speech_blocks = 0;
  $trailing_silence_blocks = 0;
  @utterance_blocks = ();
  $buffer = '';
  $i = 0;

  print "\n";
  printf "Now speak your sample %d:\n", $samples + 1;
  while ($trailing_silence_blocks < TRAILING_SILENCE_BLOCKS) {
    $stream->read($buffer, SAMPLES);
    push @utterance_blocks, $buffer;

    if (isSilence($buffer)) {
      if ($speech_blocks > MIN_SPEECH) {
        print '.';
        $trailing_silence_blocks++;
      } else {
        # No good speech collected; restart.
        print $spin[$i++], "\r";
        $i = 0 if $i == scalar @spin;
        $speech_blocks = 0;
        # FIFO - remove first block, shift array up.
        shift @utterance_blocks if scalar @utterance_blocks > FIFO_DEPTH;
      }
    } else {
      print '*' if $speech_blocks > MIN_SPEECH;
      $speech_blocks++;
      $trailing_silence_blocks = 0;
    }
  }

  printf "\n";
  printf "Utterance is %.2f seconds long (%d blocks)\n",
      (20 * (scalar @utterance_blocks) / 1000), scalar @utterance_blocks;

  $utterance[$samples] = join '', @utterance_blocks;
}
print "\n";

# Send API request to KITT.AI
$APIreq = encode_json({
  #  gender     => 'male',
  #  age_group  => '40-49',
  name       => $hotword,
  language   => $language,
  token      => $api_token,
  microphone => 'mobile',
  voice_samples => [
    {wave => encode_base64(addWavHeader($utterance[0]))},
    {wave => encode_base64(addWavHeader($utterance[1]))},
    {wave => encode_base64(addWavHeader($utterance[2]))}
  ]
});

$ua = LWP::UserAgent->new(debug => 1);
my $response = $ua->post(URL,
                         Content_Type => "application/json",
                         Content => $APIreq);

$model_dir = "data";
$time_str = time;
$hotword_name = $hotword;
$hotword_name =~ s/\s+/_/g;
if ($response->is_success) {
  # Saves the generated models in the current working directory.
  make_path($model_dir);

  # Saves samples.
  for (0..2) {
    $id = $_ + 1;
    my $fh = IO::File->new(
        ">$model_dir/${hotword_name}_${time_str}_sample${id}.wav");
    if (defined $fh) {
      print $fh addWavHeader($utterance[$_]);
      $fh->close;
    }
  }

  # Saves the generated personal model.
  my $fh = IO::File->new(">$model_dir/${hotword_name}_${time_str}.pmdl");
  if (defined $fh) {
    print $fh $response->content;
    $fh->close;
  }

  print "Model $model_dir/${hotword_name}_${time_str}.pmdl created.\n";
} else {
  print "Failed to create model:\n";
  die $response->status_line;
}

sub isSilence {
  my $samples = shift;

  # Unpack into an array of 16-bit linear samples
  my $vec = vector(unpack('s*', $samples));
  my $stddev = round(stddev($vec));

  return $stddev < $maxdev;
}

# WAV format reference: http://soundfile.sapp.org/doc/WaveFormat/
sub addWavHeader {
  my $raw = shift;
  my $header;

  my $byterate = RATE * NUMCHANNELS * BITSPERSAMPLE / 8;
  my $blockalign = NUMCHANNELS * BITSPERSAMPLE / 8;

  $header = pack('A4VA4A4VvvVVvvA4V',
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

sub round {
  my($number) = shift;
  return int($number + .5);
}
