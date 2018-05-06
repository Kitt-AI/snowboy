package main

import (
	"fmt"
	"io/ioutil"
	"unsafe"
	"os"

	"github.com/Kitt-AI/snowboy/swig/Go"
)

func main() {
	if len(os.Args) < 3 {
		fmt.Printf("usage: %s <keyword.umdl> <wav file>\n", os.Args[0])
		return
	}
	fmt.Printf("Snowboy detecting keyword in %s\n", os.Args[2])
	detector := snowboydetect.NewSnowboyDetect("../../../resources/common.res", os.Args[1])
	detector.SetSensitivity("0.5")
	detector.SetAudioGain(1)
	detector.ApplyFrontend(false)
	defer snowboydetect.DeleteSnowboyDetect(detector)

	dat, err := ioutil.ReadFile(os.Args[2])
	if err != nil {
		panic(err)
	}

	ptr := snowboydetect.SwigcptrInt16_t(unsafe.Pointer(&dat[0]))
	res := detector.RunDetection(ptr, len(dat) / 2 /* len of int16  */)
	if res == -2 {
		fmt.Println("Snowboy detected silence")
	} else if res == -1 {
		fmt.Println("Snowboy detection returned error")
	} else if res == 0 {
		fmt.Println("Snowboy detected nothing")
	} else {
		fmt.Println("Snowboy detected keyword ", res)
	}
}
