require_relative 'cacher'
require_relative 'error'

# Module with methods for using cache adapter
module Service
  module Api
    ##
    # Module/Trait for data models
    #
    module Cached
      module_function

      ##
      # Cache adapter
      #
      # @param [Cacher]

      @cacher = nil

      ##
      # Get cache adapter
      #
      # @return [Cacher]
      #
      def cacher
        return @cacher unless @cacher.nil?
        @cacher = Cacher.new(
          {
            base_name: cache_basename,
            default_namespace: cache_default_namespace
          }.merge(cache_options)
        )
      end

      protected

      ##
      # Get custom cache adapter options
      #
      # @return [Hash]
      #
      def cache_options
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
      #
      def cache_basename
        raise Error, 'Method "cache_basename" is not implemented.'
      end

      ##
      # Get default namespace
      #
      # It's recommended to overwrite this method with entity namespace
      #
      # @return [String]
      #
      def cache_default_namespace
        '_default'
      end
    end
  end
end
