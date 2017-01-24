#!/usr/bin/perl

use Snowboy;
use Fcntl;

local $/ = undef;

# Positive test
open WAV, 'resources/snowboy.wav';

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

print "HOTWORD DETECTED!\n";
  if $sb -> RunDetection ($data) > 0;
