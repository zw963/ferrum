module Ferrum
  module Utils
    module Attempt
      extend self

      def with_retry(errors : Array(Exception), max : Int32, wait : Time::Span, &)
        attempts = 1

        loop do
          begin
            yield
            break
          rescue errors
            raise if attempts >= max
            attempts += 1
            sleep wait
          end
        end
      end
    end
  end
end
