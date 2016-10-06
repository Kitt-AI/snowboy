# Example Makefile that wrappers snowboy c++ library (snowboy-detect.a) through
# JNI interface, using swig.
#
# Make sure you have jdk installed.

# Please use swig-3.0.10 or up.
SWIG := swig

SNOWBOYDETECTSWIGITF = snowboy-detect-swig.i
SNOWBOYDETECTSWIGOBJ = snowboy-detect-swig.o
SNOWBOYDETECTSWIGCC = snowboy-detect-swig.cc
SNOWBOYDETECTJAVAPKG = ai.kitt.snowboy
SNOWBOYDETECTJAVAPKGDIR = java/ai/kitt/snowboy/
SNOWBOYDETECTSWIGLIBFILE = jniLibs/libsnowboy-detect-java.so

TOPDIR := ../../
CXXFLAGS := -I$(TOPDIR) -O3 -fPIC -D_GLIBCXX_USE_CXX11_ABI=0
LDFLAGS :=

ifeq ($(shell uname), Darwin)
  CXX := clang++
  JAVAHOME := $(shell /usr/libexec/java_home)
  JAVAINC := -I$(JAVAHOME)/include -I$(JAVAHOME)/include/darwin
  SWIGFLAGS := -bundle -flat_namespace -undefined suppress
  LDLIBS := -lm -ldl -framework Accelerate
  SNOWBOYDETECTLIBFILE = $(TOPDIR)/lib/osx/libsnowboy-detect.a
  SNOWBOYDETECTSWIGLIBFILE := $(SNOWBOYDETECTSWIGLIBFILE:.so=.dylib)
else
  CXX := g++
  JAVAHOME := $(shell readlink -f $(shell which javac))
  JAVAHOME := $(shell dirname $(shell dirname $(JAVAHOME)))
  JAVAINC := -I$(JAVAHOME)/include -I$(JAVAHOME)/include/linux
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
	@-mkdir -p $(SNOWBOYDETECTJAVAPKGDIR)
	$(SWIG) -I$(TOPDIR) -c++ -java -package $(SNOWBOYDETECTJAVAPKG) -outdir \
  $(SNOWBOYDETECTJAVAPKGDIR) -o $(SNOWBOYDETECTSWIGCC) $(SNOWBOYDETECTSWIGITF)

$(SNOWBOYDETECTSWIGOBJ): $(SNOWBOYDETECTSWIGCC)
	$(CXX) $(JAVAINC) $(CXXFLAGS) -c $(SNOWBOYDETECTSWIGCC) -o $(SNOWBOYDETECTSWIGOBJ)

$(SNOWBOYDETECTSWIGLIBFILE): $(SNOWBOYDETECTSWIGOBJ) $(SNOWBOYDETECTLIBFILE)
	@-mkdir -p `dirname $(SNOWBOYDETECTSWIGLIBFILE)`
	$(CXX) $(CXXFLAGS) $(SWIGFLAGS) $(LDFLAGS) $(SNOWBOYDETECTSWIGOBJ) \
  $(SNOWBOYDETECTLIBFILE) $(LDLIBS) -o $(SNOWBOYDETECTSWIGLIBFILE)

clean:
	-rm -rf *.o *.a *.so java jniLibs $(SNOWBOYDETECTSWIGCC)
