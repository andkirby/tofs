require_relative 'error'
require_relative '../put_locker'
require_relative 'api/cached'
require_relative 'api/serial/seasons'
require_relative 'api/movie'

module Service::PutLocker::SeasonWatcher
  include Service::PutLocker::Api::Cached
  module_function

  ##
  # Get all new episodes by watch URLs list
  #
  # @param [TrueClass, FalseClass] remember_last Save last episodes
  # @return [Array]
  #
  def get_all_new_episodes(remember_last = false)
    all_list = []
    get_watch_list.each { |url|
      update = get_serial_new_episodes url, remember_last
      next if update.count == 0
      all_list.push(
        {
          :info     => get_serial_info(url),
          :episodes => update
        }
      )
    }
    all_list
  end

  ##
  # Make message for sending to slack
  #
  # @params [Array] updates
  # @return [String]
  #
  def make_send_message(updates)
    return nil if nil == updates || updates.count == 0

    message = 'Hi there! There are updates in your serials.' + "\n"

    s = 0
    updates.each { |movie|
      e = 0
      s += 1

      message += "#{s}. <#{movie[:info][:url]}|#{movie[:info][:label]}>" + "\n"
      movie[:episodes].each { |episode|
        e += 1

        message += "  #{e}. <#{episode[:season_url]}|S#{episode[:season_index]}> <#{episode[:url]}|#{episode[:label]}>" + "\n"
      }
    }
    message + 'Enjoy!'
  end

  ##
  # Get serial base info
  #
  # @return [Hash]
  #
  def get_serial_info(url, episodes: true)
    Service::PutLocker::Api::Movie::fetch_info url, episodes: episodes
  end

  ##
  # Get URLs for watching
  #
  # @param [String] url
  # @param [TrueClass, FalseClass] remember Save last episodes
  # @return [Array]
  #
  def get_serial_new_episodes(url, remember = false)
    last_episode = get_last_episode(url)
    full_list    = Service::PutLocker::Api::Serial::Seasons::fetch(url)

    if last_episode
      # last_episode[:index] = last_episode[:index] - 2
      seasons      = full_list.select { |item|
        item[:season_index] >= last_episode[:season_index]
      }
      new_episodes = get_new_episodes(seasons, last_episode)
    else
      new_episodes = get_new_episodes(full_list, {})
    end

    if remember && new_episodes
      # set_last_episode url, new_episodes.last
      set_last_episode url, new_episodes[-1]
    end
    new_episodes
  end

  # @return [Hash]

  def get_last_episode(url)
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
    get_serial_new_episodes(url, true) if fetch
    self
  end

  ##
  # Get URLs for watching
  #
  # @return [Array]
  #
  def get_watch_list
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
    unless 0 == url.index(Service::PutLocker::get_base_url + '/')
      raise Service::PutLocker::Error,
            "The url '#{url}' doesn't belong to " + Service::PutLocker::get_base_url + '.'
    end
    self
  end

  protected
  module_function

  ##
  # Define last episode in storage
  #
  # @return [Hash]
  #
  def define_last_episode(full_list, url)
    last_episode = get_list_last_episode(full_list)
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
  def get_list_last_episode(seasons)
    get_episode_data(seasons[-1], seasons[-1][:episodes][-1])
  end

  ##
  # Get complete episode data
  # It will add season base data
  #
  # @return [Hash]
  #
  def get_episode_data(season, episode)
    episode[:season]       = season[:season]
    episode[:season_index] = season[:season_index]
    episode[:season_url]   = season[:season_url]
    episode
  end

  ##
  # Get new episodes since last episode
  #
  # @return [Array]
  #
  def get_new_episodes(seasons, last_episode)
    new_episodes = []
    seasons.each { |season|
      if season[:season_index] == last_episode[:season_index]
        new_found = season[:episodes].select { |item|
          item[:index] > last_episode[:index]
        }
      else
        new_found = season[:episodes]
      end
      new_found.each { |item|
        new_episodes.push(
          get_episode_data season, item
        )
      }
    }
    new_episodes
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
  def get_cache_default_namespace
    'season_watcher'
  end

  ##
  # Get default namespace
  #
  # @return [String]

  def get_cache_options
    {:timeout => 3600}
  end

  # Declare included module functions
  module_function :cacher, :get_cache_basename
end
