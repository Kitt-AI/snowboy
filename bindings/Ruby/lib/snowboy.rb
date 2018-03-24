$: << BASE_PATH=File.dirname(__FILE__)

require 'ffi'

module Snowboy
  module Lib
    extend FFI::Library
    
    so_path = File.expand_path(File.join(BASE_PATH, '..', '..', 'C', 'libsnowboydetect.so'))
    
    if File.exist?(so_path)
      ffi_lib so_path
    else
      ffi_lib "libsnowboydetect"
    end
    
    attach_function :SnowboyDetectConstructor, [:string, :string], :pointer      
    attach_function :SnowboyDetectBitsPerSample, [:pointer], :int
    attach_function :SnowboyDetectSampleRate, [:pointer], :int
    attach_function :SnowboyDetectNumChannels, [:pointer], :int
    attach_function :SnowboyDetectNumHotwords, [:pointer], :int                
    attach_function :SnowboyDetectReset, [:pointer], :bool  
    attach_function :SnowboyDetectRunDetection, [:pointer, :pointer, :int, :bool], :int
    attach_function :SnowboyDetectSetAudioGain, [:pointer, :float], :void
    attach_function :SnowboyDetectSetSensitivity, [:pointer, :string], :void 
  end
  
  class Detector
    attr_reader :resource, :model, :sensitivity, :audio_gain, :ptr
    def initialize resource: nil, model: nil, sensitivity: 0.5, gain: 1
      @ptr = Lib::SnowboyDetectConstructor(resource, model)
           
      @resource = resource
      @model    = model
    
      self.sensitivity  = sensitivity;
      self.audio_gain   = gain;  
    end
    
    def audio_gain= gain
      @audio_gain = gain
   
      Lib::SnowboyDetectSetAudioGain(ptr, audio_gain)
    end
    
    def sensitivity= lvl
      Lib::SnowboyDetectSetSensitivity(ptr, lvl.to_s)
    end
    
    def sample_rate
      Lib::SnowboyDetectSampleRate(ptr)
    end

    def bits_per_sample
      Lib::SnowboyDetectBitsPerSample(ptr)
    end
    
    def n_channels
      Lib::SnowboyDetectNumChannels(ptr)
    end
    
    def n_hotwords
      Lib::SnowboyDetectNumHotwords(ptr)
    end        
    
    def reset
      Lib::SnowboyDetectReset(ptr)
    end    
    
    def run_detection *o
      Lib::SnowboyDetectRunDetection(ptr, *o)
    end
  end
end

