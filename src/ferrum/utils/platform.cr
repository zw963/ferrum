module Ferrum
  module Utils
    module Platform
      def self.name
        {% if flag?(:darwin) %}
          :mac
        {% elsif flag?(:win32) %}
          :windows
        {% else %}
          :linux
        {% end %}
      end
    end
  end
end
