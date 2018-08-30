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
      #
      def send(message)
        return unless message

        uri = URI.parse(@options[:webhook_url])

        http             = Net::HTTP.new uri.host, uri.port
        http.use_ssl     = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Post.new(uri.request_uri)
        # noinspection RubyResolve
        request.add_field('Accept', 'application/json')
        # noinspection RubyResolve
        request.set_form_data(payload: '{"text":"' + message + '"}')

        http.request(request)
      end

      ##
      # Init slack notifier
      #
      # @return [SlackSender::Notifier]
      #
      def init_client
        notifier = Slack::Notifier.new @options[:webhook_url]
        notifier.channel = @options[:channel] if @options[:channel]
        notifier.username = @options[:username] if @options[:username]
        notifier
      end
    end
  end
end
