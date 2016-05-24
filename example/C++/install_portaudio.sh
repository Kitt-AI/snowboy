#!/bin/bash

# This script attempts to install PortAudio, which can grap a live audio stream
# from the soundcard.

echo "Installing portaudio"

if [ ! -e pa_stable_v19_20140130.tgz ]; then
  wget -T 10 -t 3 \
    http://www.portaudio.com/archives/pa_stable_v19_20140130.tgz || exit 1;
fi

tar -xovzf pa_stable_v19_20140130.tgz || exit 1

cd portaudio
patch < ../patches/portaudio.patch

MACOS=`uname 2>/dev/null | grep Darwin`
if [ -z "$MACOS" ]; then
  ./configure --prefix=`pwd`/install --with-pic
  sed -i '40s:src/common/pa_ringbuffer.o::g' Makefile
  sed -i '40s:$: src/common/pa_ringbuffer.o:' Makefile
else
  # People may have changed OSX's default configuration -- we use clang++.
  CC=clang CXX=clang++ ./configure --prefix=`pwd`/install --with-pic
fi

make
make install

cd ..
