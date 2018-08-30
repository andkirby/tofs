require_relative '../../../service/api/cached'
require_relative '../../../service/put_locker'

# Cache adapter methods
module Service::PutLocker::Api
  module Cached
    include Service::Api::Cached

    protected

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
