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
      @port : String
      @host : String
      @timeout : Int32
      @window_size : Tuple(Int32, Int32)
      @js_errors : Bool
      @headless : Bool
      @pending_connection_errors : Bool
      @process_timeout : Int32
      @browser_options : Hash(String, String?)
      @slowmo : Float64?
      @ws_max_receive_size : Int32?
      @env : Hash(String, String)?
      @proxy : Hash(String, String)?
      @logger : Log?
      @browser_name : String?
      @browser_path : String?
      @save_path : String?
      @extensions : Array(String)?
      @ignore_default_browser_options : Bool?
      @xvfb : Xvfb?
      @base_url : URI?
      @url : String?

      def initialize(options = {} of Symbol => Log | Xvfb | Bool | String | Float64 | Int32 | Array(String) | Hash(String, String) | Tuple(Int32, Int32))
        @options = options.dup
        @port = @options.fetch(:port, BROWSER_PORT).as(String)
        @host = @options.fetch(:host, BROWSER_HOST).as(String)
        @timeout = @options.fetch(:timeout, DEFAULT_TIMEOUT).as(Int32)
        @window_size = @options.fetch(:window_size, WINDOW_SIZE).as(Tuple(Int32, Int32))
        @js_errors = @options.fetch(:js_errors, false).as(Bool)
        @headless = @options.fetch(:headless, HEADLESS).as(Bool)
        @pending_connection_errors = @options.fetch(:pending_connection_errors, true).as(Bool)
        @process_timeout = @options.fetch(:process_timeout, PROCESS_TIMEOUT).as(Int32)
        @browser_options = @options.fetch(:browser_options, {} of String => String?).as(Hash(String, String?))
        @slowmo = @options[:slowmo]?.try &.as(Float64)

        @ws_max_receive_size = @options[:ws_max_receive_size]?.try &.as(Int32)
        @env = @options[:env]?.try &.as(Hash(String, String))
        @browser_name = @options[:browser_name]?.try &.as(String)
        @browser_path = @options[:browser_path]?.try &.as(String)
        @save_path = @options[:save_path]?.try &.as(String)
        @extensions = @options[:extensions]?.try &.as(Array(String))
        @ignore_default_browser_options = @options[:ignore_default_browser_options]?.try &.as(Bool)
        @xvfb = @options[:xfb]?.try &.as(Xvfb)

        # @ws_max_receive_size, @env, @browser_name, @browser_path, @save_path, @extensions, @ignore_default_browser_options, @xvfb = @options.values_at(
        #   :ws_max_receive_size, :env, :browser_name, :browser_path, :save_path, :extensions,
        #   :ignore_default_browser_options, :xvfb
        # )

        @options[:window_size] = @window_size
        @proxy = parse_proxy(@options[:proxy]?).as(Hash(String, String)?)
        @logger = @options[:logger]?.try &.as(Log)
        @base_url = parse_base_url(@options[:base_url].as(String)) if @options[:base_url]?
        @url = @options[:url].as(String) if @options[:url]?

        @options
        @browser_options
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
