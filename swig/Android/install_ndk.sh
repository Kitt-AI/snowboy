#!/bin/bash

# This script installs NDK r11c

if [ ! -f android-ndk-r11c-linux-x86_64.zip ]; then
  wget -T 10 -t 3 https://dl.google.com/android/repository/android-ndk-r11c-linux-x86_64.zip \
  -O android-ndk-r11c-linux-x86_64.zip || exit 1;
fi

unzip android-ndk-r11c-linux-x86_64.zip || exit 1;
./android-ndk-r11c/build/tools/make-standalone-toolchain.sh --arch=arm --platform=android-17 --install-dir=`pwd`/ndk_install --use-llvm --stl=libc++ || exit 1;
