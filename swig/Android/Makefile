# Example Makefile that wrappers snowboy c++ library (snowboy-detect.a) through
# JNI interface, using swig.

# This Makefile is optimized for armv7-a architecture. Also, please make sure
# "unzip" is installed.

# Please use swig-3.0.10 or up.
SWIG := swig

# Please specify your NDK root directory here.
NDK_VERSION="r14b"
NDKINSTALLEDROOT := $(PWD)/ndk_install
NDKROOT := $(PWD)/android-ndk-${NDK_VERSION}

SNOWBOYDETECTSWIGITF = snowboy-detect-swig.i
SNOWBOYDETECTSWIGOBJ = snowboy-detect-swig.o
SNOWBOYDETECTSWIGCC = snowboy-detect-swig.cc
SNOWBOYDETECTJAVAPKG = ai.kitt.snowboy
SNOWBOYDETECTJAVAPKGDIR = java/ai/kitt/snowboy/
SNOWBOYDETECTSWIGLIBFILE = libsnowboy-detect-android.so
OPENBLASLIBFILE = OpenBLAS-Android/install/lib/libopenblas.a

ARCH := arm
TOPDIR := ../../
LDFLAGS :=

CXXFLAGS := -O3 --sysroot=$(NDKINSTALLEDROOT)/sysroot
LDLIBS := -L$(NDKINSTALLEDROOT)/sysroot/usr/lib

ifeq ($(ARCH), arm)
  AR := $(NDKINSTALLEDROOT)/bin/arm-linux-androideabi-ar
  CC := $(NDKINSTALLEDROOT)/bin/arm-linux-androideabi-gcc
  CXX := $(NDKINSTALLEDROOT)/bin/arm-linux-androideabi-g++
  STRIP := $(NDKINSTALLEDROOT)/bin/arm-linux-androideabi-strip
  OPENBLASTARGET := ARMV7
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

all: $(SNOWBOYSWIGLIBFILE) $(SNOWBOYDETECTSWIGLIBFILE)

%.a:
	$(MAKE) -C ${@D} ${@F}

$(NDKINSTALLEDROOT):
	@-./install_ndk.sh ${NDK_VERSION}

$(OPENBLASLIBFILE): $(NDKINSTALLEDROOT)
	@-./install_openblas.sh $(CC) $(AR) $(OPENBLASTARGET)

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
