module Service
  module Sender
    class SenderAbstract
      @options

      def initialize(options)
        set_options(options || {})
      end

      def set_options(options)
        @options = options
        self
      end

      def send(content)
        raise ScriptError, 'This method is not implemented.'
      end
    end
  end
end
