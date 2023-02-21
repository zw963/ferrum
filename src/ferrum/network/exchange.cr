module Ferrum
  class Network
    class Exchange
      # ID of the request.
      #
      # @return String
      getter :id

      # The intercepted request.
      #
      # @return [InterceptedRequest, nil]
      property :intercepted_request

      # The request object.
      #
      # @return [Request, nil]
      property :request

      # The response object.
      #
      # @return [Response, nil]
      property :response

      # The error object.
      #
      # @return [Error, nil]
      property :error

      @intercepted_request : BlackHole
      @request : Request
      @response : Response
      @error : Error

      #
      # Initializes the network exchange.
      #
      # @param [Page] page
      #
      # @param [String] id
      #
      def initialize(@page, @id)
        @intercepted_request = nil
        @request = nil
        @response = nil
        @error = nil
      end

      #
      # Determines if the network exchange was caused by a page navigation
      # event.
      #
      # @param [String] frame_id
      #
      # @return [Boolean]
      #
      def navigation_request?(frame_id)
        request.try &.type?(:document) && request.try &.frame_id == frame_id
      end

      #
      # Determines if the network exchange has a request.
      #
      # @return [Boolean]
      #
      def blank?
        !request
      end

      #
      # Determines if the request was intercepted and blocked.
      #
      # @return [Boolean]
      #
      def blocked?
        intercepted? && intercepted_request.status?(:aborted)
      end

      #
      # Determines if the request was blocked, a response was returned, or if an
      # error occurred.
      #
      # @return [Boolean]
      #
      def finished?
        blocked? || response.try &.loaded? || !error.nil?
      end

      #
      # Determines if the network exchange is still not finished.
      #
      # @return [Boolean]
      #
      def pending?
        !finished?
      end

      #
      # Determines if the exchange's request was intercepted.
      #
      # @return [Boolean]
      #
      def intercepted?
        !intercepted_request.nil?
      end

      #
      # Determines if the exchange is XHR.
      #
      # @return [Boolean]
      #
      def xhr?
        !!request.try &.xhr?
      end

      #
      # Returns request's URL.
      #
      # @return [String, nil]
      #
      def url
        request.try &.url
      end

      #
      # Converts the network exchange into a request, response, and error tuple.
      #
      # @return [Array]
      #
      def to_a
        [request, response, error]
      end

      #
      # Inspects the network exchange.
      #
      # @return [String]
      #
      def inspect
        "#<#{self.class} " \
        "@id=#{@id.inspect} " \
        "@intercepted_request=#{@intercepted_request.inspect} " \
        "@request=#{@request.inspect} " \
        "@response=#{@response.inspect} " \
        "@error=#{@error.inspect}>"
      end
    end
  end
end
