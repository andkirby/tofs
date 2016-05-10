require_relative 'sender_abstract'
require 'slack-notifier'
require 'openssl'

module Service
  module Sender
    class SlackSender < SenderAbstract
      ##
      # Send message to slack webhook
      #
      # @param [String] message
      # @param [Hash] options
      # @return [Net::HTTPResponse]
      #
      def send(message, options = {})
        return unless message

        init_client.ping message
      end

      ##
      # Init slack notifier
      #
      # @return [SlackSender::Notifier]
      #
      def init_client
        notifier = Slack::Notifier.new @options[:webhook_url]
        if @options[:channel]
          notifier.channel = @options[:channel]
        end
        if @options[:username]
          notifier.username = @options[:username]
        end
        notifier
      end
    end
  end
end
