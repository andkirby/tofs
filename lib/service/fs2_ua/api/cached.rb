module Service::Fs2Ua::Api
  module Cached
    ##
    # Cache adapter
    #
    # @param [Cacher]

    @cacher           = nil

    ##
    # Get cache adapter
    #
    # @return [Cacher]

    def get_cacher
      return @cacher if nil != @cacher
      @cacher = Service::Api::Cacher.new(
        {
          :base_name => get_cache_basename,
          :default_namespace => get_cache_default_namespace,
        }
      )
    end

    ##
    # Get cache basename
    #
    # It's recommended to overwrite this method with an entity basename
    #
    # @return [String]

    def get_cache_basename
      Service::Fs2Ua::HOSTNAME
    end

    ##
    # Get default namespace
    #
    # It's recommended to overwrite this method with entity namespace
    #
    # @return [String]

    def get_cache_default_namespace
      '_default'
    end
  end
end
