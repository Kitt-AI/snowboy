include ruby.mk

SHAREDLIB = lib/snowboy/ext/libsnowboydetect.so

OBJFILES = port_audio_detect.o snowboy-detect-c-wrapper.o

all: $(SHAREDLIB)

%.a:
	$(MAKE) -C ${@D} ${@F}

# We have to use the C++ compiler to link.
$(SHAREDLIB): $(PORTAUDIOLIBS) $(SNOWBOYDETECTLIBFILE) $(OBJFILES)
	-mkdir -p lib/snowboy/ext
	$(CXX) $(OBJFILES) $(SNOWBOYDETECTLIBFILE) $(PORTAUDIOLIBS) $(LDLIBS) -shared -o $(SHAREDLIB)

$(PORTAUDIOLIBS):
	@-./install_portaudio.sh

clean:
	-rm -f *.o *.a $(SHAREDLIB) $(OBJFILES)
