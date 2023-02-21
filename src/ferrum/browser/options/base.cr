module Ferrum
  class Browser
    class Options
      class Base
        # include Singleton

        def self.options
          instance
        end

        def to_h
          @@default_options
        end

        def except(*keys)
          to_h.except(*keys)
        end

        def detect_path
          Binary.find(@@platform_path[Utils::Platform.name])
        end

        def merge_required(flags, options, user_data_dir)
          raise NotImplementedError
        end

        def merge_default(flags, options)
          raise NotImplementedError
        end
      end
    end
  end
end
