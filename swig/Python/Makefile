# Example Makefile that converts snowboy c++ library (snowboy-detect.a) to
# python library (_snowboydetect.so, snowboydetect.py), using swig.

# Some versions of swig does not work well. We prefer compiling swig from source
# code. We have tested swig-3.0.7.tar.gz. 
SWIG := swig

SNOWBOYDETECTSWIGITF = snowboy-detect-swig.i
SNOWBOYDETECTSWIGOBJ = snowboy-detect-swig.o
SNOWBOYDETECTSWIGCC = snowboy-detect-swig.cc
SNOWBOYDETECTSWIGLIBFILE = _snowboydetect.so

TOPDIR := ../../
CXXFLAGS := -I$(TOPDIR) -O3 -fPIC
LDFLAGS :=

ifeq ($(shell uname), Darwin)
  CXX := clang++
  PYINC := $(shell /usr/bin/python2.7-config --includes)
  PYLIBS := $(shell /usr/bin/python2.7-config --ldflags)
  SWIGFLAGS := -bundle -flat_namespace -undefined suppress
  LDLIBS := -lm -ldl -framework Accelerate
  SNOWBOYDETECTLIBFILE = $(TOPDIR)/lib/osx/libsnowboy-detect.a
else
  CXX := g++
  PYINC := $(shell python-config --cflags)
  PYLIBS := $(shell python-config --ldflags)
  SWIGFLAGS := -shared
  CXXFLAGS += -std=c++0x
  # Make sure you have Atlas installed. You can statically link Atlas if you
  # would like to be able to move the library to a machine without Atlas.
  LDLIBS := -lm -ldl -lf77blas -lcblas -llapack_atlas -latlas
  SNOWBOYDETECTLIBFILE = $(TOPDIR)/lib/ubuntu64/libsnowboy-detect.a
  ifneq (,$(findstring arm,$(shell uname -m)))
    SNOWBOYDETECTLIBFILE = $(TOPDIR)/lib/rpi/libsnowboy-detect.a
  endif
endif

all: $(SNOWBOYSWIGLIBFILE) $(SNOWBOYDETECTSWIGLIBFILE)

%.a:
	$(MAKE) -C ${@D} ${@F}

$(SNOWBOYDETECTSWIGCC): $(SNOWBOYDETECTSWIGITF)
	$(SWIG) -I$(TOPDIR) -c++ -python -o $(SNOWBOYDETECTSWIGCC) $(SNOWBOYDETECTSWIGITF)

$(SNOWBOYDETECTSWIGOBJ): $(SNOWBOYDETECTSWIGCC)
	$(CXX) $(PYINC) $(CXXFLAGS) -c $(SNOWBOYDETECTSWIGCC)

$(SNOWBOYDETECTSWIGLIBFILE): $(SNOWBOYDETECTSWIGOBJ) $(SNOWBOYDETECTLIBFILE)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $(SWIGFLAGS) $(SNOWBOYDETECTSWIGOBJ) \
	$(SNOWBOYDETECTLIBFILE) $(PYLIBS) $(LDLIBS) -o $(SNOWBOYDETECTSWIGLIBFILE)

clean:
	-rm -f *.o *.a *.so snowboydetect.py *.pyc $(SNOWBOYDETECTSWIGCC)
