module Ferrum
  class Browser
    class Options
      class Base
        def self.options
          if (instance = @@instance)
            instance
          else
            @@instance = new
          end
        end

        @@platform_path = {
          mac:     [] of String,
          windows: [] of String,
          linux:   [] of String,
        }

        def to_h
          @@default_options
        end

        def except(*keys)
          to_h.reject(*keys)
        end

        def detect_path
          Binary.find(@@platform_path[Utils::Platform.name])
        end

        def merge_required(flags, options, user_data_dir)
          raise NotImplementedError.new
        end

        def merge_default(flags, options)
          raise NotImplementedError.new
        end
      end
    end
  end
end
