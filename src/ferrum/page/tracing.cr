module Ferrum
  class Page
    class Tracing
      EXCLUDED_CATEGORIES   = {"*"}
      SCREENSHOT_CATEGORIES = {"disabled-by-default-devtools.screenshot"}
      INCLUDED_CATEGORIES   = {
        "devtools.timeline", "v8.execute", "disabled-by-default-devtools.timeline",
        "disabled-by-default-devtools.timeline.frame", "toplevel", "blink.console",
        "blink.user_timing", "latencyInfo", "disabled-by-default-devtools.timeline.stack",
        "disabled-by-default-v8.cpu_profiler", "disabled-by-default-v8.cpu_profiler.hires",
      }
      DEFAULT_TRACE_CONFIG = {
        includedCategories: INCLUDED_CATEGORIES,
        excludedCategories: EXCLUDED_CATEGORIES,
      }

      def initialize(page)
        @page = page
        @subscribed_tracing_complete = false
      end

      #
      # Accepts block, records trace and by default returns trace data from `Tracing.tracingComplete` event as output.
      #
      # @param [String, nil] path
      #   Save data on the disk.
      #
      # @param [:binary, :base64] encoding
      #   Encode output as Base64 or plain text.
      #
      # @param [Float, nil] timeout
      #   Wait until file streaming finishes in the specified time or raise
      #   error.
      #
      # @param [Boolean] screenshots
      #   capture screenshots in the trace.
      #
      # @param [Hash{String => Object}] trace_config
      #   config for [trace](https://chromedevtools.github.io/devtools-protocol/tot/Tracing/#type-TraceConfig),
      #   for categories see [getCategories](https://chromedevtools.github.io/devtools-protocol/tot/Tracing/#method-getCategories),
      #   only one trace config can be active at a time per browser.
      #
      # @return [String, true]
      #   The trace data from the `Tracing.tracingComplete` event.
      #   When `path` is specified returns `true` and stores trace data into
      #   file.
      #
      def record(*, @path : String? = nil, @encoding = :binary, timeout = nil, trace_config = nil, screenshots = false)
        @pending = Concurrent::IVar.new
        trace_config ||= DEFAULT_TRACE_CONFIG.dup

        if screenshots
          included = trace_config.fetch(:includedCategories, [] of BlackHole)
          trace_config[:includedCategories] = included | SCREENSHOT_CATEGORIES
        end

        subscribe_tracing_complete

        start(trace_config)
        yield
        stop

        @pending.value!(timeout || @page.timeout)
      end

      private def start(config)
        @page.command("Tracing.start", transferMode: "ReturnAsStream", traceConfig: config)
      end

      private def stop
        @page.command("Tracing.end")
      end

      private def subscribe_tracing_complete
        return if @subscribed_tracing_complete

        @page.on("Tracing.tracingComplete") do |event, index|
          next if index.to_i != 0

          @pending.set(stream_handle(event["stream"]))
        rescue e
          @pending.fail(e)
        end

        @subscribed_tracing_complete = true
      end

      private def stream_handle(handle)
        @page.stream_to(path: @path, encoding: @encoding, handle: handle)
      end
    end
  end
end
