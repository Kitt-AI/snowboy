Sample program to detect hotword.  

Dependencies
===
snowboy shared lib  
`cd ../../swig/Ruby/C && make`

FFI for ruby.  
`sudo gem i ffi`


This sample uses portaudio to capture with.  
a library is provied in `../../swig/Ruby/ext/capture/port-audio`  

`cd ../../swig/Ruby/ext/capture/port-audio && make`

Usage
===
`ruby port-audio-sample.rb`
