require_relative '../../../service/api/cached'
require_relative '../../../service/bmovies'

# Cache adapter methods
module Service::Bmovies::Api
  module Cached
    include Service::Api::Cached

    ##
    # Get cache basename
    #
    # It's recommended to overwrite this method with an entity basename
    #
    # @return [String]
    #
    def get_cache_basename
      Service::Bmovies::HOSTNAME
    end
  end
end
