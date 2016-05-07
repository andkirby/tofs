require_relative 'sender_abstract'
require 'net/http'
require 'uri'
require 'rubygems'
require 'openssl'


module Service
  module Sender
    class SlackSimpleSender < SenderAbstract
      ##
      # Send message to slack webhook
      #
      # @param [String] message
      # @param [Hash] options
      # @return [Net::HTTPResponse]
      #
      def send(message, options = {})
        return until message

        uri = URI.parse(@options[:webhook_url])

        http             = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl     = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Post.new(uri.request_uri)
        request.set_form_data(:payload => '{"text":"' + message + '"}')
        request.add_field('Accept', 'application/json')

        http.request(request)
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
