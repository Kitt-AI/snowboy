# Example Makefile that wrappers snowboy c++ library (snowboy-detect.a) through
# JNI interface, using swig.

# When you extract Android toolchain from Android NDK, make sure you supply
# --stl=libc++ option. This Makefile is optimized for armv7-a architecture.
# Also, please make sure "unzip" is installed.

# Please use swig-3.0.10 or up.
SWIG := swig

# Please specify your NDK root directory here.
NDKINSTALLEDROOT := $(PWD)/ndk_install
NDKROOT := $(PWD)/android-ndk-r11c

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
  CXXFLAGS += -shared -std=c++0x -rdynamic -I$(TOPDIR) -Wl,--fix-cortex-a8 \
      -Wl,--no-warn-mismatch -Wl,--no-undefined -Wl,-z,noexecstack \
      -Wl,-z,relro -Wl,-z,now -Wl,--warn-shared-textrel -Wl,--fatal-warnings \
      -Wno-sign-compare -Wa,--noexecstack -Wformat -Werror=format-security \
      -fno-rtti -ffunction-sections -funwind-tables -fstack-protector-strong \
      -fomit-frame-pointer -fno-strict-aliasing -finline-limit=64 \
      -fno-strict-aliasing -mthumb -no-canonical-prefixes -march=armv7-a \
      -mfpu=vfpv3-d16 -mhard-float -D_NDK_MATH_NO_SOFTFP=1 -DANDROID
  LDLIBS += \
      -L$(NDKROOT)/sources/cxx-stl/llvm-libc++/libs/armeabi-v7a-hard/thumb/ \
      -lc++_static -lgcc -lm_hard -ldl -lc -lm
  SNOWBOYDETECTSWIGLIBFILE := jniLibs/armeabi-v7a/$(SNOWBOYDETECTSWIGLIBFILE)
  SNOWBOYDETECTSWIGLIBNAME := $(shell basename $(SNOWBOYDETECTSWIGLIBFILE))
endif

all: $(SNOWBOYSWIGLIBFILE) $(SNOWBOYDETECTSWIGLIBFILE)

%.a:
	$(MAKE) -C ${@D} ${@F}

$(NDKINSTALLEDROOT):
	@-./install_ndk.sh

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
