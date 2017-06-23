include demo.mk

BINFILE = demo

OBJFILES = demo.o snowboy-detect-c-wrapper.o

all: $(BINFILE)

%.a:
	$(MAKE) -C ${@D} ${@F}

# We have to use the C++ compiler to link.
$(BINFILE): $(PORTAUDIOLIBS) $(SNOWBOYDETECTLIBFILE) $(OBJFILES)
	$(CXX) $(OBJFILES) $(SNOWBOYDETECTLIBFILE) $(PORTAUDIOLIBS) $(LDLIBS) -o $(BINFILE)

$(PORTAUDIOLIBS):
	@-./install_portaudio.sh

clean:
	-rm -f *.o *.a $(BINFILE) $(OBJFILES)
