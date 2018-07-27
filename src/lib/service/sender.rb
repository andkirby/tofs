require_relative 'sender/slack_sender'
require_relative 'sender/slack_simple_sender'

module Service
  module Sender
    module_function

    def get(name)
      if name == :slack
        return Service::Sender::SlackSender
      elsif name == :slack_simple
        return Service::Sender::SlackSimpleSender
      end
      raise
    end
  end
end
