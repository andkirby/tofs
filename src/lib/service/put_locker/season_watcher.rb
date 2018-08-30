require_relative 'error'
require_relative '../put_locker'
require_relative 'api/cached'
require_relative 'api/serial/seasons'
require_relative 'api/movie'

module Service
  module PutLocker
    ##
    # Season watcher model
    #
    class SeasonWatcher
      @movie = nil

      include Service::Api::Cached
      include Service::PutLocker::Api::Cached

      def initialize(movie: nil, seasons: nil)
        @movie   = movie || Service::PutLocker::Api::Movie.new
        @seasons = seasons || Service::PutLocker::Api::Serial::Seasons.new
      end

      ##
      # Get all new episodes by watch URLs list
      #
      # @param [TrueClass, FalseClass] remember_last Save last episodes
      # @return [Array]
      #
      def all_new_episodes(remember_last = false)
        all_list = []
        watch_list.each do |url|
          update = episodes_diff url, remember_last
          next if update.count.zero?
          all_list.push(
            info:     serial_info(url),
            episodes: update
          )
        end
        all_list
      end

      ##
      # Make message for sending to slack
      #
      # @params [Array] updates
      # @return [String]
      #
      def create_message(updates)
        return nil if updates.nil? || updates.count.zero?

        message = 'Hi there! There are updates in your serials.' + "\n"

        s = 0
        updates.each do |movie|
          e = 0
          s += 1

          message += "#{s}. <#{movie[:info][:url]}|#{movie[:info][:label]}>" + "\n"
          movie[:episodes].each do |episode|
            e += 1

            message += "  #{e}. <#{episode[:season_url]}|S#{episode[:season_index]}> <#{episode[:url]}|#{episode[:label]}>" + "\n"
          end
        end
        message + 'Enjoy!'
      end

      ##
      # Get serial base info
      #
      # @return [Hash]
      #
      def serial_info(url, episodes: true)
        movie.fetch url, episodes: episodes
      end

      def movie
        @movie
      end

      ##
      # Get URLs for watching
      #
      # @param [String] url
      # @param [TrueClass, FalseClass] remember Save last episodes
      # @return [Array]
      #
      def episodes_diff(url, remember = false)
        last_episode = last_episode(url)
        full_list    = @seasons.fetch(url)

        if last_episode
          # last_episode[:index] = last_episode[:index] - 2
          seasons = full_list.select do |item|
            item[:season_index] >= last_episode[:season_index]
          end
          list    = fetch_new_episodes(seasons, last_episode)
        else
          list = fetch_new_episodes(full_list, {})
        end

        if remember && list
          # set_last_episode url, list.last
          set_last_episode url, list[-1]
        end
        list
      end

      # @return [Hash]

      def last_episode(url)
        cacher.get 'last-episode-' + url
      end

      ##
      # Add URL to watch with possible fetching all and save last episode
      #
      # @param [String] url
      # @return [self]
      #
      def add_to_watch(url, fetch = false)
        # add url to the list
        add_url url
        # define last movie episode
        episodes_diff(url, true) if fetch
        self
      end

      ##
      # Get URLs for watching
      #
      # @return [Array]
      #
      def watch_list
        cacher.get('urls') || []
      end

      ##
      # Add URL for watching
      #
      # @return [Array]
      #
      def add_url(url)
        # [Array] list
        list = cacher.get('urls') || []
        return self if list.include?(url)

        valid_url?(url)

        list.push url

        timeout = 3600 * 24 * 365 * 5 # set long timeout
        cacher.put 'urls', list, nil, timeout

        self
      end

      ##
      # Check if URL matched with base one
      #
      # @return [Array]
      #
      def valid_url?(url)
        unless url.index(Service::PutLocker.base_url + '/').zero?
          raise Service::PutLocker::Error,
                "The url '#{url}' doesn't belong to " +
                  Service::PutLocker.base_url + '.'
        end
        self
      end

      protected

      ##
      # Define last episode in storage
      #
      # @return [Hash]
      #
      def define_last_episode(full_list, url)
        last_episode = list_last_episode(full_list)
        set_last_episode(
          url,
          last_episode
        )
        last_episode
      end

      ##
      # Get last episode
      #
      # @return [Hash]
      #
      def list_last_episode(seasons)
        filter_episode(seasons[-1], seasons[-1][:episodes][-1])
      end

      ##
      # Get complete episode data
      # It will add season base data
      #
      # @return [Hash]
      #
      def filter_episode(season, episode)
        episode[:season]       = season[:season]
        episode[:season_index] = season[:season_index]
        episode[:season_url]   = season[:season_url]
        episode
      end

      ##
      # Fetch new episodes since last episode
      #
      # @return [Array]
      #
      def fetch_new_episodes(seasons, last_episode)
        list = []
        seasons.each do |season|
          season_new_episode(season, last_episode).each do |item|
            list.push filter_episode(season, item)
          end
        end
        list
      end

      ##
      # Set last episode to storage
      #
      # @param [String] url
      # @param [Hash] last_episode
      # @return [self]
      #
      def set_last_episode(url, last_episode)
        timeout = 3600 * 24 * 365 * 5 # set long timeout
        cacher.put 'last-episode-' + url, last_episode, nil, timeout

        self
      end

      ##
      # Get default namespace
      #
      # @return [String]
      #
      def cache_default_namespace
        'season_watcher'
      end

      ##
      # Get default namespace
      #
      # @return [String]

      def cache_options
        { timeout: 3600 }
      end

      private

      def season_new_episode(season, last_episode)
        if season[:season_index] == last_episode[:season_index]
          season[:episodes].select do |item|
            item[:index] > last_episode[:index]
          end
        else
          season[:episodes]
        end
      end
    end
  end
end
