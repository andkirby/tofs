require_relative '../../../service/api/cached'
require_relative '../../../service/put_locker'

# Cache adapter methods
module Service
  module PutLocker
    module Api
      ##
      # Service Cached module/trait
      #
      module Cached

        # protected

        ##
        # Get cache basename
        #
        # It's recommended to overwrite this method with an entity basename
        #
        # @return [String]
        #
        def cache_basename
          Service::PutLocker::HOSTNAME
        end
      end
    end
  end
end
