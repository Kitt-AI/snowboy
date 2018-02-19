## Dependencies

### Swig
http://www.swig.org/

### Go Package alongside the more idiomatic wrapper `go-snowboy`, plus PortAudio
```
github.com/brentnd/go-snowboy
github.com/gordonklaus/portaudio
```

## Building

```
go build -o listen main.go
```

## Running

```
./listen [path to snowboy resource file] [path to snowboy hotword file]
```

### Examples
Cmd:
`./listen ../../../resources/common.res ../../../resources/models/snowboy.umdl`

Output:
```
sample rate=16000, num channels=1, bit depth=16
Silence detected.
Silence detected.
Silence detected.
You said the hotword!
Silence detected.
```
