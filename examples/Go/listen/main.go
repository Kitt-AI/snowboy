// This example streams the microphone thru Snowboy to listen for the hotword,
// by using the PortAudio interface.
//
// HOW TO USE:
// 	go run examples/Go/listen/main.go [path to snowboy resource file] [path to snowboy hotword file]
//
package main

import (
	"bytes"
	"encoding/binary"
	"fmt"
	"os"
	"time"

	"github.com/brentnd/go-snowboy"
	"github.com/gordonklaus/portaudio"
)

// Sound represents a sound stream implementing the io.Reader interface
// that provides the microphone data.
type Sound struct {
	stream *portaudio.Stream
	data   []int16
}

// Init initializes the Sound's PortAudio stream.
func (s *Sound) Init() {
	inputChannels := 1
	outputChannels := 0
	sampleRate := 16000
	s.data = make([]int16, 1024)

	// initialize the audio recording interface
	err := portaudio.Initialize()
	if err != nil {
		fmt.Errorf("Error initialize audio interface: %s", err)
		return
	}

	// open the sound input stream for the microphone
	stream, err := portaudio.OpenDefaultStream(inputChannels, outputChannels, float64(sampleRate), len(s.data), s.data)
	if err != nil {
		fmt.Errorf("Error open default audio stream: %s", err)
		return
	}

	err = stream.Start()
	if err != nil {
		fmt.Errorf("Error on stream start: %s", err)
		return
	}

	s.stream = stream
}

// Close closes down the Sound's PortAudio connection.
func (s *Sound) Close() {
	s.stream.Close()
	portaudio.Terminate()
}

// Read is the Sound's implementation of the io.Reader interface.
func (s *Sound) Read(p []byte) (int, error) {
	s.stream.Read()

	buf := &bytes.Buffer{}
	for _, v := range s.data {
		binary.Write(buf, binary.LittleEndian, v)
	}

	copy(p, buf.Bytes())
	return len(p), nil
}

func main() {
	// open the mic
	mic := &Sound{}
	mic.Init()
	defer mic.Close()

	// open the snowboy detector
	d := snowboy.NewDetector(os.Args[1])
	defer d.Close()

	// set the handlers
	d.HandleFunc(snowboy.NewHotword(os.Args[2], 0.5), func(string) {
		fmt.Println("You said the hotword!")
	})

	d.HandleSilenceFunc(1*time.Second, func(string) {
		fmt.Println("Silence detected.")
	})

	// display the detector's expected audio format
	sr, nc, bd := d.AudioFormat()
	fmt.Printf("sample rate=%d, num channels=%d, bit depth=%d\n", sr, nc, bd)

	// start detecting using the microphone
	d.ReadAndDetect(mic)
}
