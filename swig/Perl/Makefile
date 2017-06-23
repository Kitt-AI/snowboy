# Example Makefile that wraps snowboy c++ library (snowboy-detect.a) into
# a Perl module (Snowboy.pm) using swig.

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


SNOWBOYDETECTSWIGITF = snowboy-detect.i
SNOWBOYDETECTSWIGOBJ = snowboy-detect-swig.o
SNOWBOYDETECTSWIGCC = snowboy-detect-swig.cc
SNOWBOYDETECTSWIGLIBFILE = Snowboy.so

TOPDIR := ../../
CXXFLAGS := -I$(TOPDIR) -O3 -fPIC -D_GLIBCXX_USE_CXX11_ABI=0
LDFLAGS :=

ifeq ($(shell uname), Darwin)
  CXX := clang++
  PERLARCH := $(shell perl -e 'use Config; print $$Config{archlib}')
  SWIGFLAGS := -bundle -flat_namespace -undefined suppress
  CXXFLAGS += -I$(PERLARCH)/CORE
  LDLIBS := -lm -ldl -framework Accelerate
  SNOWBOYDETECTLIBFILE = $(TOPDIR)/lib/osx/libsnowboy-detect.a
  SNOWBOYDETECTSWIGLIBFILE := Snowboy.dylib
else
  CXX := g++
  PERLARCH := $(shell perl -e 'use Config; print $$Config{archlib}')
  SWIGFLAGS := -shared
  CXXFLAGS += -std=gnu++11 -I$(PERLARCH)/CORE
	# Make sure you have Atlas installed. You can statically link Atlas if you
	# would like to be able to move the library to a machine without Atlas.
  LDLIBS := -lm -ldl -lf77blas -lcblas -llapack_atlas -latlas
  SNOWBOYDETECTLIBFILE = $(TOPDIR)/lib/ubuntu64/libsnowboy-detect.a
  ifneq (,$(findstring arm,$(shell uname -m)))
    SNOWBOYDETECTLIBFILE = $(TOPDIR)/lib/rpi/libsnowboy-detect.a
    ifeq ($(findstring fc,$(shell uname -r)), fc)
      SNOWBOYDETECTLIBFILE = $(TOPDIR)/lib/fedora25-armv7/libsnowboy-detect.a
      LDLIBS := -L/usr/lib/atlas -lm -ldl -lsatlas
    endif
  endif
endif

all: $(SNOWBOYSWIGLIBFILE) $(SNOWBOYDETECTSWIGLIBFILE)

%.a:
	$(MAKE) -C ${@D} ${@F}

$(SNOWBOYDETECTSWIGCC): $(SNOWBOYDETECTSWIGITF)
	$(SWIG) -I$(TOPDIR) -c++ -perl -o $(SNOWBOYDETECTSWIGCC) $(SNOWBOYDETECTSWIGITF)

$(SNOWBOYDETECTSWIGOBJ): $(SNOWBOYDETECTSWIGCC)
	$(CXX) $(CXXFLAGS) -c $(SNOWBOYDETECTSWIGCC)

$(SNOWBOYDETECTSWIGLIBFILE): $(SNOWBOYDETECTSWIGOBJ) $(SNOWBOYDETECTLIBFILE)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $(SWIGFLAGS) $(SNOWBOYDETECTSWIGOBJ) \
	$(SNOWBOYDETECTLIBFILE) $(LDLIBS) -o $(SNOWBOYDETECTSWIGLIBFILE)

clean:
	-rm -f *.o *.a *.so *.dylib Snowboy.pm $(SNOWBOYDETECTSWIGCC)
