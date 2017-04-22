#!/bin/bash

# This script compiles OpenBLAS for Android with ARM architecture. The prebuilt
# Android NDK toolchains do not include Fortran, hence parts like LAPACK will
# not be built.

CC=$1
AR=$2
TARGET=$3
DIR=$4

if [ ! -d $DIR ]; then
  git clone https://github.com/xianyi/OpenBLAS.git $DIR
  cd $DIR
  git checkout arm_soft_fp_abi || exit 1;
  git reset --hard b5c96fcfcdc82945502a2303116a64d89985daf5 || exit 1;
  cd ..
fi

cd $DIR
make USE_THREAD=0 TARGET=${TARGET} HOSTCC=gcc CC=${CC} AR=${AR} \
  NOFORTRAN=1 ARM_SOFTFP_ABI=1 libs || exit 1;
make PREFIX=`pwd`/install install || exit 1;
