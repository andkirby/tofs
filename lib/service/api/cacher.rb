require 'timedcache'

module Service
  module Api
    # Cache adapter
    class Cacher
      @cache_dir
      @adapters
      @base_name
      @use_base_name
      @timeout

      # Init options
      #
      # @param [Hash] options

      def initialize(options = {})
        @base_name         = options[:base_name]
        @default_namespace = options[:default_namespace]
        @timeout           = options[:timeout] || 24 * 3600 * 365
        @cache_dir         = options[:cache_dir] || __dir__ + '/../../../.cache'
        @use_base_name     = (options.key? :use_base_name) ? options[:use_base_name] : true
        @adapters          = {}
      end

      ##
      # Get cacher
      #
      # @param [String] namespace
      # @return [TimedCache]

      def get_adapter (namespace = nil)
        namespace = @default_namespace if namespace == nil

        return @adapters[namespace] if @adapters[namespace]

        file            = get_cache_file(namespace, @use_base_name)
        @adapters[file] = TimedCache.new(
          {:type => 'file', :filename => file, :default_timeout => @timeout}
        )
      end

      ##
      # Read cache
      #
      # @param [String] key
      # @param [String] namespace
      # @return [string]

      def get(key, namespace = nil)
        get_adapter(namespace).get(key)
      end

      ##
      # Write cache
      #
      # @param [String] key
      # @param [String] namespace
      # @return [string]

      def put(key, value, namespace = nil)
        get_adapter(namespace).put(key, value)
      end

      protected

      ##
      # Get cache file
      #
      # @param [String] namespace
      # @param [TrueClass FalseClass] use_base_name
      # @return [string]

      def get_cache_file(namespace, use_base_name)
        file = @cache_dir + '/' +
          (use_base_name ? get_base_cache_key + '/' : '') +
          (safe_name(namespace) || 'main') + '.txt'
        # TODO Check writing
        FileUtils.mkpath File.dirname(file)
        file
      end

      ##
      # Get base cache key
      #
      # @return [String]

      def get_base_cache_key
        return @base_cache_key if @base_cache_key
        @base_cache_key = safe_name(@base_name)
      end

      ##
      # Make safe string
      #
      # @return [String]

      def safe_name(name)
        name.gsub('/', '-',)
          .gsub(':', '-')
          .gsub('?', '-')
          .gsub('&', '-')
          .gsub('=', '-')
          .gsub('.', '-')
      end
    end
  end
end
