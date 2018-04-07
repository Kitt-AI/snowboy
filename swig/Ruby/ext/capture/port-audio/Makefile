include port-audio-capture.mk

SHAREDLIB = port-audio-capture.so

OBJFILES = port-audio-capture.o

all: $(SHAREDLIB)

%.a:
	$(MAKE) -C ${@D} ${@F}

# We have to use the C++ compiler to link.
$(SHAREDLIB): $(PORTAUDIOLIBS) $(OBJFILES)
	$(CXX) $(OBJFILES) $(PORTAUDIOLIBS) $(LDLIBS) -shared -o $(SHAREDLIB)

$(PORTAUDIOLIBS):
	@-./install_portaudio.sh

clean:
	-rm -f *.o *.a $(SHAREDLIB) $(OBJFILES)
