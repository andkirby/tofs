require_relative '../../../service/api/cached'
require_relative '../../../service/fs2_ua'

# Cache adapter methods
module Service::Fs2Ua::Api
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
      Service::Fs2Ua::HOSTNAME
    end
  end
end
