require_relative '../../../service/api/cached'
require_relative '../../../service/bmovies'

# Cache adapter methods
module Service
  module Bmovies
    module Api
      ##
      # Service module for cached models
      #
      module Cached
        include Service::Api::Cached

        ##
        # Get cache basename
        #
        # It's recommended to overwrite this method with an entity basename
        #
        # @return [String]
        #
        def cache_basename
          Service::Bmovies::HOSTNAME
        end
      end
    end
  end
end
