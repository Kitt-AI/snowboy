include libsnowboydetect.mk

SHAREDLIB = libsnowboydetect.so

OBJFILES = snowboy-detect-c-wrapper.o

all: $(SHAREDLIB)

%.a:
	$(MAKE) -C ${@D} ${@F}

# We have to use the C++ compiler to link.
$(SHAREDLIB): $(SNOWBOYDETECTLIBFILE) $(OBJFILES)
	$(CXX) $(OBJFILES) $(SNOWBOYDETECTLIBFILE) $(LDLIBS) -shared -o $(SHAREDLIB)

clean:
	-rm -f *.o *.a $(SHAREDLIB) $(OBJFILES)
