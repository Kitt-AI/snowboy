Ruby bindings for `snowboy`  

Dependencies
===
snowboy shared lib  
`cd ../C && make`

Extra
===
A simple audio capture tool is provided in `./ext/capture/port-audio`  
`cd ./ext/capture/port-audio && make`

Usage
===
```ruby
require "./lib/snowboy"

snowboy = Snowboy::Detect.new(resource: resource_path, model: model_path)

# get audio data
# ...

result = snowboy.run_detection(data, data_length, false)

if result > 0
  # handle result
end 
```

