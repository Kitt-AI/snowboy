include demo.mk

BINFILES = demo

all: $(BINFILES)

%.a:
	$(MAKE) -C ${@D} ${@F}

$(BINFILES): $(SNOWBOYDETECTLIBFILE)

clean:
	-rm -f *.o *.a $(BINFILES)

depend:
	-$(CXX) -M $(CXXFLAGS) *.cc > .depend.mk

# Putting "-" so no error messages.
-include .depend.mk
