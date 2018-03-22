$: << BASE_PATH=File.dirname(__FILE__)

require 'ffi'

module Snowboy
  module Lib
    extend FFI::Library
    ffi_lib File.join(BASE_PATH, 'snowboy', 'ext', 'libsnowboydetect.so')
    
    attach_function :SnowboyDetectConstructor, [:string, :string], :pointer
    attach_function :StartAudioCapturing, [:int, :int, :int], :void
    attach_function :SnowboyDetectBitsPerSample, [:pointer], :int
    attach_function :SnowboyDetectSampleRate, [:pointer], :int
    attach_function :SnowboyDetectNumChannels, [:pointer], :int
    attach_function :SnowboyDetectNumHotwords, [:pointer], :int                
    attach_function :SnowboyDetectReset, [:pointer], :bool
    attach_function :StopAudioCapturing, [], :void
    attach_function :SnowboyDetectRunDetection, [:pointer, :pointer, :int, :bool], :int
    attach_function :LoadAudioData, [], :int
    attach_function :SnowboyDetectSetAudioGain, [:pointer, :float], :void
    attach_function :SnowboyDetectSetSensitivity, [:pointer, :string], :void 
    attach_variable :g_data, :g_data, :pointer       
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
    
    def run &b
      capture
  
      @run = true
  
      @thread = Thread.new do
        begin
          while @run    
            if (length = load_audio_data) > 0
              b.call run_detection(g_data, length, false)
            end
          end
        rescue => e
          puts e
          puts e.backtrace.join("\n")
        end
        
        @run = false
      end
    end

    def stop
      @run = false
      @thread.kill if @thread
      stop_capture
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
    
    def running?
      @run
    end
    
    private
    def capture
      rate     = sample_rate 
      channels = n_channels
      bps      = bits_per_sample
      
      Lib::StartAudioCapturing(rate, channels, bps)
    end
    
    private
    def stop_capture
      Lib::StopAudioCapturing()
    end    
    
    private
    def load_audio_data
      Lib::LoadAudioData()
    end
    
    private
    def g_data
      Lib.g_data;
    end
    
    private
    def run_detection *o
      Lib::SnowboyDetectRunDetection(ptr, *o)
    end
  end
end
