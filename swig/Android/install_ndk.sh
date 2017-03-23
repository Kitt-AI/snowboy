#!/bin/bash

# This script installs NDK r11c

UNAME_INFO=`uname -a`
NDK_REPOSITORY_URL="https://dl.google.com/android/repository/"

if [[ $UNAME_INFO == *"Darwin"* ]]; then
  if [ ! -d "android-ndk-r11c" ]; then
    wget -T 10 -t 3 ${NDK_REPOSITORY_URL}/android-ndk-r11c-darwin-x86_64.zip \
      -O android-ndk-r11c-darwin-x86_64.zip || exit 1;
  fi
  unzip android-ndk-r11c-darwin-x86_64.zip 1>/dev/null || exit 1;
elif [[ $UNAME_INFO == *"Linux"* ]]; then
  if [ ! -d "android-ndk-r11c" ]; then
    wget -T 10 -t 3 ${NDK_REPOSITORY_URL}/android-ndk-r11c-linux-x86_64.zip \
      -O android-ndk-r11c-linux-x86_64.zip || exit 1;
  fi
  unzip android-ndk-r11c-linux-x86_64.zip 1>/dev/null || exit 1;
else
  echo "Your platform is not supported yet." || exit 1;
fi

./android-ndk-r11c/build/tools/make-standalone-toolchain.sh \
  --arch=arm --platform=android-14 --install-dir=`pwd`/ndk_install || exit 1;
