include demo.mk

BINFILES = demo demo2

all: $(BINFILES)

%.a:
	$(MAKE) -C ${@D} ${@F}

$(BINFILES): $(PORTAUDIOLIBS) $(SNOWBOYDETECTLIBFILE)

$(PORTAUDIOLIBS):
	@-./install_portaudio.sh

clean:
	-rm -f *.o *.a $(BINFILES)

depend:
	-$(CXX) -M $(CXXFLAGS) *.cc > .depend.mk

# Putting "-" so no error messages.
-include .depend.mk
