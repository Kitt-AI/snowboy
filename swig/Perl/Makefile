# Example Makefile that wraps snowboy c++ library (snowboy-detect.a) into
# a Perl module (Snowboy.pm) using swig.

# Please use swig-3.0.10 or up.
SWIG := swig

SNOWBOYDETECTSWIGITF = snowboy-detect.i
SNOWBOYDETECTSWIGOBJ = snowboy-detect-swig.o
SNOWBOYDETECTSWIGCC = snowboy-detect-swig.cc
SNOWBOYDETECTSWIGLIBFILE = Snowboy.so

TOPDIR := ../../
CXXFLAGS := -I$(TOPDIR) -O3 -fPIC -D_GLIBCXX_USE_CXX11_ABI=0
LDFLAGS :=

CXX := g++
PERLARCH := $(shell perl -e 'use Config; print $$Config{archlib}')
SWIGFLAGS := -shared
CXXFLAGS += -std=gnu++11 -I$(PERLARCH)/CORE -L$(PERLARCH)/CORE

# Make sure you have OpenBLAS installed
LDLIBS := -lm -ldl -Wl,--whole-archive -lopenblas -Wl,--no-whole-archive

SNOWBOYDETECTLIBFILE = $(TOPDIR)/lib/ubuntu64/libsnowboy-detect.a

ifneq (,$(findstring arm,$(shell uname -m)))
  SNOWBOYDETECTLIBFILE = $(TOPDIR)/lib/rpi/libsnowboy-detect.a
endif

all: $(SNOWBOYSWIGLIBFILE) $(SNOWBOYDETECTSWIGLIBFILE)

%.a:
	$(MAKE) -C ${@D} ${@F}

$(SNOWBOYDETECTSWIGCC): $(SNOWBOYDETECTSWIGITF)
	$(SWIG) -I$(TOPDIR) -c++ -perl5 -o $(SNOWBOYDETECTSWIGCC) $(SNOWBOYDETECTSWIGITF)

$(SNOWBOYDETECTSWIGOBJ): $(SNOWBOYDETECTSWIGCC)
	$(CXX) $(PYINC) $(CXXFLAGS) -c $(SNOWBOYDETECTSWIGCC)

$(SNOWBOYDETECTSWIGLIBFILE): $(SNOWBOYDETECTSWIGOBJ) $(SNOWBOYDETECTLIBFILE)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $(SWIGFLAGS) $(SNOWBOYDETECTSWIGOBJ) \
	$(SNOWBOYDETECTLIBFILE) $(PYLIBS) $(LDLIBS) -o $(SNOWBOYDETECTSWIGLIBFILE)

clean:
	-rm -f *.o *.a *.so Snowboy.pm $(SNOWBOYDETECTSWIGCC)
