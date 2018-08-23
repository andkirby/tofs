require_relative 'cacher'
require_relative 'error'

# Module with methods for using cache adapter
module Service
  module Api
    module Cached
      ##
      # Cache adapter
      #
      # @param [Cacher]

      @cacher = nil

      ##
      # Get cache adapter
      #
      # @return [Cacher]

      def cacher
        return @cacher unless nil == @cacher
        @cacher = Cacher.new(
          {
            :base_name         => get_cache_basename,
            :default_namespace => get_cache_default_namespace,
          }.merge get_cache_options
        )
      end

      protected

      ##
      # Get custom cache adapter options
      #
      # @return [Hash]

      def get_cache_options
        {}
      end

      ##
      # Get cache basename
      #
      # It's recommended to overwrite this method with an entity basename
      # Common directory with this name will be created for cache files
      # (for default cache adapter).
      #
      # @return [String]

      def get_cache_basename
        raise Error, 'Method "get_cache_basename" is not implemented.'
      end

      ##
      # Get default namespace
      #
      # It's recommended to overwrite this method with entity namespace
      #
      # @return [String]

      def self.get_cache_default_namespace
        '_default'
      end
    end
  end
end
