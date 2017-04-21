#!/bin/bash

# This script installs NDK with version number as parameter
# Usage: ./install_ndk.sh [ndk version] (such as "r14b")

UNAME_INFO=`uname -a`
NDK_REPOSITORY_URL="https://dl.google.com/android/repository/"
NDK_VERSION=$1
BIT=$2

if [[ $UNAME_INFO == *"Darwin"* ]]; then
  if [ ! -d "android-ndk-${NDK_VERSION}" ]; then
    wget -T 10 -t 3 ${NDK_REPOSITORY_URL}/android-ndk-${NDK_VERSION}-darwin-x86_64.zip \
      -O android-ndk-${NDK_VERSION}-darwin-x86_64.zip || exit 1;
    unzip android-ndk-${NDK_VERSION}-darwin-x86_64.zip 1>/dev/null || exit 1;
  fi
elif [[ $UNAME_INFO == *"Linux"* ]]; then
  if [ ! -d "android-ndk-${NDK_VERSION}" ]; then
    wget -T 10 -t 3 ${NDK_REPOSITORY_URL}/android-ndk-${NDK_VERSION}-linux-x86_64.zip \
      -O android-ndk-${NDK_VERSION}-linux-x86_64.zip || exit 1;
    unzip android-ndk-${NDK_VERSION}-linux-x86_64.zip 1>/dev/null || exit 1;
  fi
else
  echo "Your platform is not supported yet." || exit 1;
fi

if [[ $BIT == *"64"* ]]; then
    ./android-ndk-${NDK_VERSION}/build/tools/make-standalone-toolchain.sh --verbose \
      --arch=arm64 --platform=android-21 --install-dir=`pwd`/ndk_install_64bit || exit 1;
else
    ./android-ndk-${NDK_VERSION}/build/tools/make-standalone-toolchain.sh --verbose \
      --arch=arm --platform=android-14 --install-dir=`pwd`/ndk_install_32bit || exit 1;
fi
