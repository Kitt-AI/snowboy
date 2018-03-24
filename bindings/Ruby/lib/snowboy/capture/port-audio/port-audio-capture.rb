module Snowboy
  module Capture
    class PortAudio
      module Lib
        extend FFI::Library
        
        ffi_lib File.expand_path(File.join(File.dirname(__FILE__), "..", '..', '..', '..', 'ext', 'capture', 'port-audio', 'port-audio-capture.so'))
      
        attach_function :rb_snowboy_port_audio_capture_start_audio_capturing, [:pointer, :int, :int, :int], :void
        attach_function :rb_snowboy_port_audio_capture_stop_audio_capturing, [:pointer], :void
        attach_function :rb_snowboy_port_audio_capture_load_audio_data, [:pointer], :int       
        attach_function :rb_snowboy_port_audio_capture_get_audio_data, [:pointer], :pointer    
        attach_function :rb_snowboy_port_audio_capture_new, [], :pointer      
      end
      
      attr_reader :ptr
      def initialize
        @ptr = Lib.rb_snowboy_port_audio_capture_new()
      end
      
      def start_capture(rate, channels, bps)
        Lib.rb_snowboy_port_audio_capture_start_audio_capturing(@ptr, rate, channels, bps)
      end
      
      def stop_capture
        @running = false
        Lib.rb_snowboy_port_audio_capture_stop_audio_capturing(@ptr)
      end
      
      def load_audio_data
        Lib.rb_snowboy_port_audio_capture_load_audio_data(@ptr)
      end
      
      def get_audio_data
        Lib.rb_snowboy_port_audio_capture_get_audio_data(@ptr)
      end
      
      attr_accessor :thread
      def run(rate, channels, bps, &b)
        raise ArgumentError.new("No Block passed") unless b
      
        @running = true
        
        start_capture(rate, channels, bps)
        
        @thread = Thread.new do
          begin
            while running?
              if (len=load_audio_data) > 0
                b.call(get_audio_data, len)
              end
            end
          
            stop_capture
          rescue => e
            puts e
            puts e.backtrace.join("\n")
            stop_capture
          end
        end
      end
      
      def running?
        @running
      end
    end
  end
end
