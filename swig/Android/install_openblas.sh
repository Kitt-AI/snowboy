#!/bin/bash

# This script compiles OpenBLAS for Android with the given architecture. The
# prebuild Android NDK toolchains do not include Fortran, hence parts like
# LAPACK will not be built.

CC=$1
AR=$2
TARGET=$3

if [ ! -f OpenBLAS-0.2.18.tar.gz ]; then
  wget -T 10 -t 3 https://codeload.github.com/xianyi/OpenBLAS/tar.gz/v0.2.18 \
  -O OpenBLAS-0.2.18.tar.gz || exit 1;
fi

tar -xvzf OpenBLAS-0.2.18.tar.gz 1>/dev/null || exit 1;
mv OpenBLAS-0.2.18 OpenBLAS-Android

cd OpenBLAS-Android
make TARGET=${TARGET} HOSTCC=gcc CC=${CC} AR=${AR} NOFORTRAN=1 || exit 1;
make PREFIX=`pwd`/install install || exit 1;
