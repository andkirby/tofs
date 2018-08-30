require 'slack-notifier'
require 'colorize'

require_relative 'command_error'
require_relative '../api/cached'
require_relative '../../sender'
require_relative '../season_watcher'
require_relative '../api/serial/seasons'

# API methods for CLI commands
module Service
  module PutLocker
    module Cli
      ##
      # Base CLI API module
      #
      class CommandApi
        include Service::Api::Cached
        include Service::PutLocker::Api::Cached

        attr_reader :watcher

        def initialize(watcher: nil, movie: nil)
          @watcher = watcher || Service::PutLocker::SeasonWatcher.new(movie: movie)
        end

        def add_urls(urls)
          raise ArgumentError, 'Non-Array argument.' unless urls.instance_of? Array
          raise CommandError, 'Nothing to add. URLs list is empty.' if urls.empty?

          urls.each { |url| watcher.add_to_watch url }
          self
        end

        def urls
          watcher.watch_list
        end

        ##
        # Get serial info
        #
        # @param [String] url
        # @return [Hash]
        #
        def info(url)
          watcher.serial_info url
        end

        ##
        # Get last episode
        #
        # @param [String] url
        # @return [Hash]
        #
        def last_episode(url)
          watcher.last_episode url
        end

        ##
        # Get last episode
        #
        # @param [String] url
        # @return [Hash]
        #
        def fetch_last_episode(url)
          watcher.episodes_diff(url).last
        end

        ##
        # Fetch new episodes
        #
        # @param [TrueClass, FalseClass] remember_last Save last episodes
        # @return [String] Output message
        #
        def fetch_new_episodes(remember_last = false)
          watcher.all_new_episodes remember_last
        end

        ##
        # Fetch news message
        #
        # @param [TrueClass, FalseClass] remember_last Save last episodes
        # @return [String] Output message
        #
        def fetch_news_message(remember_last = false)
          watcher.create_message(
            fetch_new_episodes(remember_last)
          )
        end

        ##
        # Send message about new episodes
        #
        # @return [String] Output message
        def send_update
          message = fetch_news_message
          sender.send(message)

          # cache last episodes after sent request
          fetch_new_episodes true

          # TODO: Return cli-human readable message
          message
        end

        # region Slack methods

        # @return [Service::Sender::SenderAbstract]
        def sender
          raise CommandError, 'Slack webhook URL is not defined.' unless slack_webhook_url

          Service::Sender.get(:slack_simple).new(
            webhook_url: slack_webhook_url
          )
        end

        ##
        # Get Slack webhook URL
        #
        # @return [self]
        #
        def slack_webhook_url
          cacher.get 'slack-webhook-url'
        end

        ##
        # Define Slack webhook URL
        #
        # @param [String] url
        # @return [self]
        #
        def slack_webhook_url=(url)
          raise CommandError, 'Slack webhook URL is empty.' unless url
          cacher.put 'slack-webhook-url', url, nil, 24 * 3600 * 365 * 5
        end

        # endregion

        ##
        # Get default namespace
        #
        # It's recommended to overwrite this method with entity namespace
        #
        # @return [String]
        #
        def cache_default_namespace
          'cli'
        end
      end
    end
  end
end
