module Ferrum
  class Network
    class Error
      setter :canceled
      getter :time, :timestamp
      property :id, :url, :type, :error_text, :monotonic_time, :description

      def canceled?
        @canceled
      end

      def timestamp=(value)
        @timestamp = value
        @time = Time.parse_local((value / 1000).to_s, "%s")
      end
    end
  end
end
