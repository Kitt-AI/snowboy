TOPDIR := ../../
DYNAMIC := True
CC = $(CXX)
CXX :=
LDFLAGS :=
LDLIBS :=
PORTAUDIOINC := portaudio/install/include
PORTAUDIOLIBS := portaudio/install/lib/libportaudio.a

CXXFLAGS += -D_GLIBCXX_USE_CXX11_ABI=0

ifeq ($(DYNAMIC), True)
  CXXFLAGS += -fPIC
endif

ifeq ($(shell uname -m | cut -c 1-3), x86)
  CXXFLAGS += -msse  -msse2
endif

ifeq ($(shell uname), Darwin)
  # By default Mac uses clang++ as g++, but people may have changed their
  # default configuration.
  CXX := clang++
  CXXFLAGS += -I$(TOPDIR) -Wall -Wno-sign-compare -Winit-self \
      -DHAVE_POSIX_MEMALIGN -DHAVE_CLAPACK -I$(PORTAUDIOINC)
  LDLIBS += -ldl -lm -framework Accelerate -framework CoreAudio \
      -framework AudioToolbox -framework AudioUnit -framework CoreServices \
      $(PORTAUDIOLIBS)
  SNOWBOYDETECTLIBFILE := $(TOPDIR)/lib/osx/libsnowboy-detect.a
else ifeq ($(shell uname), Linux)
  CXX := g++
  CXXFLAGS += -I$(TOPDIR) -std=c++0x -Wall -Wno-sign-compare \
      -Wno-unused-local-typedefs -Winit-self -rdynamic \
      -DHAVE_POSIX_MEMALIGN -I$(PORTAUDIOINC)
  LDLIBS += -ldl -lm -Wl,-Bstatic -Wl,-Bdynamic -lrt -lpthread $(PORTAUDIOLIBS)\
      -L/usr/lib/atlas-base -lf77blas -lcblas -llapack_atlas -latlas -lasound
  SNOWBOYDETECTLIBFILE := $(TOPDIR)/lib/ubuntu64/libsnowboy-detect.a
  ifneq (,$(findstring arm,$(shell uname -m)))
    SNOWBOYDETECTLIBFILE := $(TOPDIR)/lib/rpi/libsnowboy-detect.a
  endif
endif

# Suppress clang warnings...
COMPILER = $(shell $(CXX) -v 2>&1 )
ifeq ($(findstring clang,$(COMPILER)), clang)
  CXXFLAGS += -Wno-mismatched-tags -Wno-c++11-extensions
endif

# Set optimization level.
CXXFLAGS += -O3
