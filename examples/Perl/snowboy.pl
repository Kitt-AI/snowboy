#!/usr/bin/perl

use Snowboy;
use Fcntl;

local $/ = undef;

# Positive test
open WAV, 'resources/snowboy.wav';

# Negative test
# open WAV, 'resources/notasnowboy.wav';

# Silence test
# open WAV, 'resources/ding.wav';

$data = <WAV>;
close WAV;

$sb =  new Snowboy::SnowboyDetect ('resources/common.res', 'resources/snowboy.umdl');

$sb -> SetSensitivity ("0.5");
$sb -> SetAudioGain (1);

print "==== SnowBoy object properties ====\n";
print "Sample Rate         : ", $sb -> SampleRate(), "\n";
print "Number of Channels  : ", $sb -> NumChannels(), "\n";
print "Bits per Sample     : ", $sb -> BitsPerSample(), "\n";
print "Number of hotwords  : ", $sb -> NumHotwords(), "\n\n";

if ((my $rc = $sb -> RunDetection ($data)) == 1) {
  print "HOTWORD DETECTED!\n";
}
else {
  print "NO HOTWORD DETECTED, ERROR: $rc\n";
}
