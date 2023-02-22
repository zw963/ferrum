require "uri"

module Ferrum
  class Browser
    class Options
      HEADLESS        = true
      BROWSER_PORT    = "0"
      BROWSER_HOST    = "127.0.0.1"
      WINDOW_SIZE     = {1024, 768}
      BASE_URL_SCHEMA = {"http", "https"}
      DEFAULT_TIMEOUT = ENV.fetch("FERRUM_DEFAULT_TIMEOUT", "5").to_i
      PROCESS_TIMEOUT = ENV.fetch("FERRUM_PROCESS_TIMEOUT", "10").to_i
      DEBUG_MODE      = !ENV.fetch("FERRUM_DEBUG", nil).nil?

      getter :window_size, :timeout, :logger, :ws_max_receive_size,
        :js_errors, :base_url, :slowmo, :pending_connection_errors,
        :url, :env, :process_timeout, :browser_name, :browser_path,
        :save_path, :extensions, :proxy, :port, :host, :headless,
        :ignore_default_browser_options, :browser_options, :xvfb

      @base_url : URI?
      @url : String?

      def initialize(@options = BrowserBaseOption.new)
        # options.dup 会造成类型不一样吗？
        # @options = options.dup
        @port = @options.port || BROWSER_PORT
        @host = @options.host || BROWSER_HOST
        @timeout = @options.timeout || DEFAULT_TIMEOUT
        @window_size = @options.window_size || WINDOW_SIZE
        @js_errors = @options.js_errors || false
        @headless = @options.headless || HEADLESS
        @pending_connection_errors = @options.pending_connection_errors || true
        @process_timeout = @options.process_timeout || PROCESS_TIMEOUT
        @browser_options = @options.browser_options || {} of String => String?
        @slowmo = @options.slowmo

        @ws_max_receive_size = @options.ws_max_receive_size
        @env = @options.env
        @browser_name = @options.browser_name
        @browser_path = @options.browser_path
        @save_path = @options.save_path
        @extensions = @options.extensions
        @ignore_default_browser_options = @options.ignore_default_browser_options
        @xvfb = @options.xvfb

        @options.window_size = @window_size
        @proxy = parse_proxy(@options.proxy).as(Hash(String, String)?)
        @logger = @options.logger

        if (base_url = @options.base_url)
          @base_url = parse_base_url(base_url)
        end

        if (url = @options.url)
          @url = url
        end
      end

      def to_h
        @options
      end

      def parse_base_url(value)
        parsed = URI.parse(value)
        unless BASE_URL_SCHEMA.includes?(parsed.try &.normalize.scheme)
          raise ArgumentError.new "`base_url` should be absolute and include schema: #{BASE_URL_SCHEMA.join(" | ")}"
        end

        parsed
      end

      def parse_proxy(options)
        return unless options

        raise ArgumentError.new "proxy options must be a Hash" unless options.is_a?(Hash)

        if options[:host].nil? && options[:port].nil?
          raise ArgumentError.new "proxy options must be a Hash with at least :host | :port"
        end

        options
      end

      # private def parse_logger(logger)
      #   return logger if logger

      #   !logger && DEBUG_MODE ? STDOUT.tap { |s| s.sync = true } : logger
      # end
    end
  end
end
