#!/usr/bin/perl

use Snowboy;
use Fcntl;

# Positive test.
open WAV, 'resources/snowboy.wav';

# Set $INPUT_RECORD_SEPARATOR to undef so that we can read the full file.
local $/ = undef;
$data = <WAV>;
close WAV;

$sb = new Snowboy::SnowboyDetect('resources/common.res',
                                 'resources/models/snowboy.umdl');

$sb->SetSensitivity ("0.5");
$sb->SetAudioGain (1);
$sb->ApplyFrontend (0);

print "==== SnowBoy object properties ====\n";
print "Sample Rate         : ", $sb->SampleRate(), "\n";
print "Number of Channels  : ", $sb->NumChannels(), "\n";
print "Bits per Sample     : ", $sb->BitsPerSample(), "\n";
print "Number of hotwords  : ", $sb->NumHotwords(), "\n\n";

if ($sb->RunDetection($data) > 0) {
  print "Unit test passed!\n"
} else {
  print "Unit test failed!\n"
}
