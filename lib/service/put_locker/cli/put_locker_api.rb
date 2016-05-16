require 'slack-notifier'
require 'colorize'

require_relative 'command_error'
require_relative '../api/cached'
require_relative '../../sender'
require_relative '../season_watcher'
require_relative '../api/serial/seasons'

module Service
  module PutLocker
    module Cli
      module PutLockerApi
        include Service::PutLocker::Api::Cached
        module_function

        def add_urls(urls)
          raise ArgumentError, 'Non-Array argument.' unless urls.instance_of? Array
          raise CommandError, 'Empty urls list.' if urls.empty?

          urls.each { |url| get_watcher::add_to_watch url }
          self
        end

        def get_urls
          get_watcher::get_watch_list
        end

        ##
        # Get serial info
        #
        # @param [String] url
        # @return [Hash]
        #
        def get_info(url)
          get_watcher::get_serial_info url
        end

        ##
        # Get last episode
        #
        # @param [String] url
        # @return [Hash]
        #
        def get_last_episode(url)
          get_watcher::get_last_episode url
        end

        ##
        # Get last episode
        #
        # @param [String] url
        # @return [Hash]
        #
        def fetch_last_episode(url)
          get_watcher::get_serial_new_episodes(url).last
        end

        ##
        # Fetch new episodes
        #
        # @param [TrueClass, FalseClass] remember_last Save last episodes
        # @return [String] Output message
        #
        def fetch_new_episodes(remember_last = false)
          get_watcher::get_all_new_episodes remember_last
        end

        ##
        # Fetch news message
        #
        # @param [TrueClass, FalseClass] remember_last Save last episodes
        # @return [String] Output message
        #
        def fetch_news_message(remember_last = false)
          get_watcher::make_send_message(
            fetch_new_episodes remember_last
          )
        end

        ##
        # Send message about new episodes
        #
        # @return [String] Output message
        def send_news_message
          message = fetch_news_message
          get_sender.send(message)

          # cache last episodes after sent request
          fetch_new_episodes true

          # TODO Return cli-human readable message
          message
        end

        # region Slack methods

        # @return [Service::Sender::SenderAbstract]
        def get_sender
          url = get_slack_webhook_url
          raise CommandError, 'Slack webhook URL is not defined.' unless url

          Service::Sender::get(:slack_simple).new(
            {:webhook_url => url}
          )
        end

        ##
        # Get Slack webhook URL
        #
        # @return [self]
        #
        def get_slack_webhook_url
          get_cacher.get 'slack-webhook-url'
        end

        ##
        # Define Slack webhook URL
        #
        # @param [String] url
        # @return [self]
        #
        def set_slack_webhook_url(url)
          raise CommandError, 'Slack webhook URL is empty.' unless url
          timeout = 24 * 3600 * 365 * 5
          get_cacher.put 'slack-webhook-url', url, nil, timeout
          self
        end

        # endregion

        protected
        module_function

        # @return [Service::PutLocker::SeasonWatcher]
        def get_watcher
          Service::PutLocker::SeasonWatcher
        end

        ##
        # Get default namespace
        #
        # It's recommended to overwrite this method with entity namespace
        #
        # @return [String]
        #
        def self.get_cache_default_namespace
          'cli'
        end

        # Declare included module functions
        module_function :get_cacher, :get_cache_basename, :get_cache_options
      end
    end
  end
end
