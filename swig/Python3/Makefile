# Example Makefile that converts snowboy c++ library (snowboy-detect.a) to
# python3 library (_snowboydetect.so, snowboydetect.py), using swig.

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


SNOWBOYDETECTSWIGITF = snowboy-detect-swig.i
SNOWBOYDETECTSWIGOBJ = snowboy-detect-swig.o
SNOWBOYDETECTSWIGCC = snowboy-detect-swig.cc
SNOWBOYDETECTSWIGLIBFILE = _snowboydetect.so

TOPDIR := ../../
CXXFLAGS := -I$(TOPDIR) -O3 -fPIC -D_GLIBCXX_USE_CXX11_ABI=0
LDFLAGS :=

ifeq ($(shell uname), Darwin)
  CXX := clang++
  PYINC := $(shell python3-config --includes)
  # If you use Anaconda, the command `python3-config` will not return full path.
  # In this case, please manually specify the full path like the following:
  # PYLIBS := -L/Users/YOURNAME/anaconda3/lib/python3.6/config-3.6m-darwin -lpython3.6m -ldl -framework CoreFoundation
  PYLIBS := $(shell python3-config --ldflags)
  SWIGFLAGS := -bundle -flat_namespace -undefined suppress
  LDLIBS := -lm -ldl -framework Accelerate
  SNOWBOYDETECTLIBFILE = $(TOPDIR)/lib/osx/libsnowboy-detect.a
else
  CXX := g++
  PYINC := $(shell python3-config --cflags)
  PYLIBS := $(shell python3-config --ldflags)
  SWIGFLAGS := -shared
  CXXFLAGS += -std=c++0x
  # Make sure you have Atlas installed. You can statically link Atlas if you
  # would like to be able to move the library to a machine without Atlas.
  ifneq ("$(ldconfig -p | grep lapack_atlas)","")
    LDLIBS := -lm -ldl -lf77blas -lcblas -llapack_atlas -latlas
  else
    LDLIBS := -lm -ldl -lf77blas -lcblas -llapack -latlas
  endif
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
	$(SWIG) -I$(TOPDIR) -c++ -python -o $(SNOWBOYDETECTSWIGCC) $(SNOWBOYDETECTSWIGITF)

$(SNOWBOYDETECTSWIGOBJ): $(SNOWBOYDETECTSWIGCC)
	$(CXX) $(PYINC) $(CXXFLAGS) -c $(SNOWBOYDETECTSWIGCC)

$(SNOWBOYDETECTSWIGLIBFILE): $(SNOWBOYDETECTSWIGOBJ) $(SNOWBOYDETECTLIBFILE)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $(SWIGFLAGS) $(SNOWBOYDETECTSWIGOBJ) \
	$(SNOWBOYDETECTLIBFILE) $(PYLIBS) $(LDLIBS) -o $(SNOWBOYDETECTSWIGLIBFILE)

clean:
	-rm -f *.o *.a *.so snowboydetect.py *.pyc $(SNOWBOYDETECTSWIGCC)
