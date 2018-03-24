$: << File.join(File.dirname(__FILE__), "..", "..", "bindings", "Ruby", "lib")


require "snowboy"
require "snowboy/capture/port-audio/port-audio-capture"

resource_path = "../../resources/common.res"
model_path    = "../../resources/models/snowboy.umdl"

snowboy = Snowboy::Detector.new(model: model_path, resource: resource_path, gain: 1, sensitivity: 0.5)
pac     = Snowboy::Capture::PortAudio.new

puts "Listening... press Ctrl-c to exit."

pac.run(snowboy.sample_rate, snowboy.n_channels, snowboy.bits_per_sample) do |data, length|
  result = snowboy.run_detection(data, length, false)
  
  if result > 0
    puts "Hotword %d detected." % result
  end
end

while true; end
