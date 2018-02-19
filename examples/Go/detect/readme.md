## Dependencies

### Swig
http://www.swig.org/

### Go Package
```
go get github.com/Kitt-AI/snowboy/swig/Go
```

## Building

```
go build -o snowboy main.go
```

## Running

```
./snowboy <keyword.umdl> <wav file>
```

### Examples
Cmd:
`./snowboy ../../../resources/models/snowboy.umdl ../../../resources/snowboy.wav`

Output:
```
Snowboy detecting keyword in ../../resources/snowboy.wav
Snowboy detected keyword  1
```

Cmd:
`./snowboy ../../resources/alexa.umdl ../../resources/snowboy.wav`

Output:
```
Snowboy detecting keyword in ../../resources/snowboy.wav
Snowboy detected nothing
```
