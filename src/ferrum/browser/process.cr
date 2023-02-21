# require "net/http"
require "json"

# require "addressable"
require "./options/base"

require "./options/chrome"
require "./options/firefox"
require "./command"

module Ferrum
  class Browser
    class Process
      @xvfb : BlackHole?
      @user_data_dir : BlackHole?

      KILL_TIMEOUT =    2
      WAIT_KILLED  = 0.05

      getter :host, :port, :ws_url, :pid, :command,
        :default_user_agent, :browser_version, :protocol_version,
        :v8_version, :webkit_version, :xvfb

      delegate path, to: @command

      def self.start(*args)
        new(*args).tap(&.start)
      end

      def self.process_killer(pid)
        proc do
          if Utils::Platform.windows?
            # Process.signal is unreliable on Windows
            ::Process.signal("KILL", pid) unless system("taskkill /f /t /pid #{pid} >NUL 2>NUL")
          else
            ::Process.signal("USR1", pid)
            start = Utils::ElapsedTime.monotonic_time
            while ::Process.wait(pid, ::Process::WNOHANG).nil?
              sleep(WAIT_KILLED)
              next unless Utils::ElapsedTime.timeout?(start, KILL_TIMEOUT)

              ::Process.signal("KILL", pid)
              ::Process.wait(pid)
              break
            end
          end
        rescue RuntimeError
          # nop
        end
      end

      def self.directory_remover(path)
        proc {
          begin
            FileUtils.remove_entry(path)
          rescue
            RuntimeError
          end
        }
      end

      def initialize(options)
        @pid = nil
        @xvfb = nil
        @user_data_dir = nil

        if options.url
          url = URI.join(options.url, "/json/version")
          response = JSON.parse(::Net::HTTP.get(url))
          self.ws_url = response["webSocketDebuggerUrl"]
          parse_browser_versions
          return
        end

        @logger = options.logger
        @process_timeout = options.process_timeout
        @env = options.env

        tempfile = File.tempfile("ferrum_user_data_dir_")
        path = tempfile.path
        tempfile.delete
        tmpdir = Dir.mkdir_p(path)

        ObjectSpace.define_finalizer(self, self.class.directory_remover(tmpdir))
        @user_data_dir = tmpdir
        @command = Command.build(options, tmpdir)
      end

      def start
        # Don't do anything as browser is already running as external process.
        return if ws_url

        begin
          read_io, write_io = IO.pipe
          process_options = {in: File::NULL}
          process_options[:pgroup] = true unless Utils::Platform.windows?
          process_options[:out] = process_options[:err] = write_io

          if @command.xvfb?
            @xvfb = Xvfb.start(@command.options)
            ObjectSpace.define_finalizer(self, self.class.process_killer(@xvfb.pid))
          end

          env = @xvfb.try(&.to_env).try &.merge(@env)
          @pid = ::Process.new(env, *@command.to_a, process_options)
          ObjectSpace.define_finalizer(self, self.class.process_killer(@pid))

          parse_ws_url(read_io, @process_timeout)
          parse_browser_versions
        ensure
          close_io(read_io, write_io)
        end
      end

      def stop
        if @pid
          kill(@pid)
          kill(@xvfb.pid) if @xvfb.try &.pid
          @pid = nil
        end

        remove_user_data_dir if @user_data_dir
        ObjectSpace.undefine_finalizer(self)
      end

      def restart
        stop
        start
      end

      private def kill(pid)
        self.class.process_killer(pid).call
      end

      private def remove_user_data_dir
        self.class.directory_remover(@user_data_dir).call
        @user_data_dir = nil
      end

      private def parse_ws_url(read_io, timeout)
        output = ""
        start = Utils::ElapsedTime.monotonic_time
        max_time = start + timeout
        regexp = %r{DevTools listening on (ws://.*[a-zA-Z0-9-]{36})}
        while (now = Utils::ElapsedTime.monotonic_time) < max_time
          begin
            output += read_io.read_nonblock(512)
          rescue IO::WaitReadable
            read_io.wait_readable(max_time - now)
          else
            if output.match(regexp)
              self.ws_url = output.match(regexp)[1].strip
              break
            end
          end
        end

        return if ws_url

        @logger.try &.puts(output)
        raise ProcessTimeoutError.new(timeout, output)
      end

      private def ws_url=(url)
        @ws_url = Addressable::URI.parse(url)
        @host = @ws_url.host
        @port = @ws_url.port
      end

      private def parse_browser_versions
        return unless ws_url.is_a?(Addressable::URI)

        version_url = URI.parse(ws_url.merge(scheme: "http", path: "/json/version"))
        response = JSON.parse(::Net::HTTP.get(version_url))

        @v8_version = response["V8-Version"]
        @browser_version = response["Browser"]
        @webkit_version = response["WebKit-Version"]
        @default_user_agent = response["User-Agent"]
        @protocol_version = response["Protocol-Version"]
      end

      private def close_io(*ios)
        ios.each do |io|
          io.close unless io.closed?
        rescue IOError
          raise unless RUBY_ENGINE == "jruby"
        end
      end
    end
  end
end
