# frozen_string_literal: true

module Ferrum
  class Browser
    class Options
      class Firefox < Base
        @@default_options = {
          "headless" => nil,
        }

        MAC_BIN_PATH = {
          "/Applications/Firefox.app/Contents/MacOS/firefox-bin",
        }

        LINUX_BIN_PATH = {"firefox"}

        WINDOWS_BIN_PATH = {
          "C:/Program Files/Firefox Developer Edition/firefox.exe",
          "C:/Program Files/Mozilla Firefox/firefox.exe",
        }

        @@platform_path = {
          mac:     MAC_BIN_PATH,
          windows: WINDOWS_BIN_PATH,
          linux:   LINUX_BIN_PATH,
        }

        def merge_required(flags, options, user_data_dir)
          flags.merge({"remote-debugger" => "#{options.host}:#{options.port}",
                       "profile"         => user_data_dir})
        end

        def merge_default(flags, options)
          defaults = except("headless") unless options.headless

          defaults ||= DEFAULT_OPTIONS
          defaults.merge(flags)
        end
      end
    end
  end
end
