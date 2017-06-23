# Example Makefile that wrappers snowboy c++ library (snowboy-detect.a) through
# JNI interface, using swig.

# This Makefile is optimized for armv7-a/armv8 architecture. Also, please make sure
# "unzip" is installed.
# Usage:
# make # for 32bit ARM
# make BIT=64 # for 64bit ARM

# Please use swig-3.0.10 or up.
SWIG := swig

SWIG_VERSION := $(shell expr `$(SWIG) -version | grep -i Version | \
	sed "s/^.* //g" | sed -e "s/\.\([0-9][0-9]\)/\1/g" -e "s/\.\([0-9]\)/0\1/g" \
	-e "s/^[0-9]\{3,4\}$$/&00/"` \>= 30010)

ifeq ($(SWIG_VERSION), 0)
checkversion:
	$(info You need at least Swig 3.0.10 to run)
	$(info Your current version is $(shell $(SWIG) -version | grep -i Version))
	@exit -1
endif


NDK_VERSION=r14b
BIT = 32
ifeq ($(BIT), 64)
    NDKINSTALLEDROOT := $(PWD)/ndk_install_64bit
    OPENBLASTARGET := ARMV8
    OPENBLASDIR := OpenBLAS-Android-ARM64
else
    NDKINSTALLEDROOT := $(PWD)/ndk_install_32bit
    OPENBLASTARGET := ARMV7
    OPENBLASDIR := OpenBLAS-Android-ARM32
endif
NDKROOT := $(PWD)/android-ndk-${NDK_VERSION}

SNOWBOYDETECTSWIGITF = snowboy-detect-swig.i
SNOWBOYDETECTSWIGOBJ = snowboy-detect-swig.o
SNOWBOYDETECTSWIGCC = snowboy-detect-swig.cc
SNOWBOYDETECTJAVAPKG = ai.kitt.snowboy
SNOWBOYDETECTJAVAPKGDIR = java/ai/kitt/snowboy/
SNOWBOYDETECTSWIGLIBFILE = libsnowboy-detect-android.so
OPENBLASLIBFILE = $(OPENBLASDIR)/install/lib/libopenblas.a

ARCH := arm
TOPDIR := ../../
LDFLAGS :=

CXXFLAGS := -O3 --sysroot=$(NDKINSTALLEDROOT)/sysroot
LDLIBS := -L$(NDKINSTALLEDROOT)/sysroot/usr/lib

ifeq ($(ARCH), arm)
  ifeq ($(BIT), 64)
      AR := $(NDKINSTALLEDROOT)/bin/aarch64-linux-android-ar
      CC := $(NDKINSTALLEDROOT)/bin/aarch64-linux-android-gcc
      CXX := $(NDKINSTALLEDROOT)/bin/aarch64-linux-android-g++
      STRIP := $(NDKINSTALLEDROOT)/bin/aarch64-linux-android-strip
      SNOWBOYDETECTLIBFILE = $(TOPDIR)/lib/android/armv8-aarch64/libsnowboy-detect.a
      CXXFLAGS += -std=c++0x -rdynamic -I$(TOPDIR) -Werror -Wall \
          -fsigned-char -fpic -fPIC -march=armv8-a \
          -DNDEBUG -ffast-math -fomit-frame-pointer -O3 -pie -fPIE -DHAVE_NEON=1 \
          -fno-strict-aliasing -Wno-unused-function -shared
      LDLIBS += \
          -L$(NDKROOT)/sources/cxx-stl/gnu-libstdc++/4.9/libs/arm64-v8a \
          -lgnustl_static -lsupc++ -lgcc -ldl -lc -lm -llog -pthread
      SNOWBOYDETECTSWIGLIBFILE := jniLibs/arm64-v8a/$(SNOWBOYDETECTSWIGLIBFILE)
      SNOWBOYDETECTSWIGLIBNAME := $(shell basename $(SNOWBOYDETECTSWIGLIBFILE))
  else
      AR := $(NDKINSTALLEDROOT)/bin/arm-linux-androideabi-ar
      CC := $(NDKINSTALLEDROOT)/bin/arm-linux-androideabi-gcc
      CXX := $(NDKINSTALLEDROOT)/bin/arm-linux-androideabi-g++
      STRIP := $(NDKINSTALLEDROOT)/bin/arm-linux-androideabi-strip
      SNOWBOYDETECTLIBFILE = $(TOPDIR)/lib/android/armv7a/libsnowboy-detect.a
      CXXFLAGS += -std=c++0x -rdynamic -I$(TOPDIR) -Werror -Wall \
          -fsigned-char -fpic -fPIC -mfloat-abi=softfp -march=armv7-a -mfpu=neon \
          -DNDEBUG -ffast-math -fomit-frame-pointer -O3 -pie -fPIE -DHAVE_NEON=1 \
          -fno-strict-aliasing -Wno-unused-function -shared
      LDLIBS += \
          -L$(NDKROOT)/sources/cxx-stl/gnu-libstdc++/4.9/libs/armeabi-v7a \
          -lgnustl_static -lsupc++ -lgcc -ldl -lc -lm -llog -pthread
      SNOWBOYDETECTSWIGLIBFILE := jniLibs/armeabi-v7a/$(SNOWBOYDETECTSWIGLIBFILE)
      SNOWBOYDETECTSWIGLIBNAME := $(shell basename $(SNOWBOYDETECTSWIGLIBFILE))
  endif
endif

all: $(SNOWBOYSWIGLIBFILE) $(SNOWBOYDETECTSWIGLIBFILE)

%.a:
	$(MAKE) -C ${@D} ${@F}

$(NDKINSTALLEDROOT):
	@-./install_ndk.sh ${NDK_VERSION} ${BIT}

$(OPENBLASLIBFILE): $(NDKINSTALLEDROOT)
	@-./install_openblas.sh $(CC) $(AR) $(OPENBLASTARGET) $(OPENBLASDIR)

$(SNOWBOYDETECTSWIGCC): $(SNOWBOYDETECTSWIGITF)
	@-mkdir -p $(SNOWBOYDETECTJAVAPKGDIR)
	$(SWIG) -I$(TOPDIR) -c++ -java -package $(SNOWBOYDETECTJAVAPKG) -outdir \
  $(SNOWBOYDETECTJAVAPKGDIR) -o $(SNOWBOYDETECTSWIGCC) $(SNOWBOYDETECTSWIGITF)

$(SNOWBOYDETECTSWIGOBJ): $(SNOWBOYDETECTSWIGCC)
	$(CXX) $(CXXFLAGS) -c $(SNOWBOYDETECTSWIGCC) -o $(SNOWBOYDETECTSWIGOBJ)

$(SNOWBOYDETECTSWIGLIBFILE): $(OPENBLASLIBFILE) $(SNOWBOYDETECTSWIGOBJ) $(SNOWBOYDETECTLIBFILE)
	@-mkdir -p `dirname $(SNOWBOYDETECTSWIGLIBFILE)`
	$(CXX) -Wl,-soname,$(SNOWBOYDETECTSWIGLIBNAME) $(CXXFLAGS) $(LDFLAGS) \
  $(SNOWBOYDETECTSWIGOBJ) $(SNOWBOYDETECTLIBFILE) $(OPENBLASLIBFILE) \
  $(LDLIBS) -o $(SNOWBOYDETECTSWIGLIBFILE)
	$(STRIP) --strip-unneeded $(SNOWBOYDETECTSWIGLIBFILE)

clean:
	-rm -rf *.o *.a *.so java jniLibs $(SNOWBOYDETECTSWIGCC)
