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
    attach_function :SnowboyDetectUpdateModel, [:pointer], :void
    attach_function :SnowboyDetectApplyFrontend, [:pointer, :bool], :void    
    attach_function :SnowboyDetectRunDetection, [:pointer, :pointer, :int, :bool], :int
    attach_function :SnowboyDetectSetAudioGain, [:pointer, :float], :void
    attach_function :SnowboyDetectSetSensitivity, [:pointer, :string], :void 
  end
  
  class Detector
    attr_reader :resource, :model, :sensitivity, :audio_gain, :ptr
    
    # @param +model+ <Array|String> pointing to the model file(s)
    #                               
    def initialize resource: nil, model: nil, sensitivity: 0.5, gain: 1
      model = value2str(model)
    
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
    
    # @param +lvl+ <Array|String> specifying levels per model
    #
    def sensitivity= lvl
      @sensitivity = o=value2str(lvl)
      
      Lib::SnowboyDetectSetSensitivity(ptr, o)
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
    
    def apply_frontend bool
      Lib::SnowboyDetectApplyFrontend(ptr, bool)
    end
    
    def update_model
      Lib::SnowboyDetectUpdateModel(ptr)
    end   
    
    def run_detection *o
      Lib::SnowboyDetectRunDetection(ptr, *o)
    end
    
    private
    def value2str obj
      if obj.is_a?(String)
        obj
      elsif obj.is_a?(Array)
        obj.map do |o|
          o.to_s
        end.join(",")
      elsif obj.is_a?(Numeric)
        obj.to_s
      else
        obj.to_s
      end
    end
  end
end

