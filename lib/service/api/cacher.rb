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
      @debug = false

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
        @debug             = !!options[:debug]

        require 'colorize' if @debug

        if @debug
          debug '@base_name '.yellow + @base_name
          debug '@timeout '.yellow + @timeout.to_s
          debug '@cache_dir '.yellow + @cache_dir
          debug '@default_namespace '.yellow + @default_namespace.to_s
        end
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
        # debug
        debug(__method__.to_s.cyan + ' key:'.yellow + " #{key}, " +
                'ns:'.yellow + ' ' +
                (namespace || @default_namespace).to_s) if @debug

        get_adapter(namespace).get(key)
      end

      ##
      # Write cache
      #
      # @param [String] key
      # @param [String, NilClass] namespace
      # @param [Integer, NilClass] timeout
      # @return [string]

      def put(key, value, namespace = nil, timeout = nil)
        timeout = get_adapter(namespace).default_timeout if timeout == nil

        # debug
        debug(__method__.to_s.cyan + ' key:'.yellow + " #{key}, " + 'ns:'.yellow +
                ' ' + (namespace || @default_namespace).to_s +
                'timeout:'.yellow + " #{timeout}") if @debug

        get_adapter(namespace).put(key, value, timeout)
        self
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
          (namespace ? safe_name(namespace) : 'main') + '.txt'
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
        raise "It's not a string." unless name.instance_of? String

        name.gsub('/', '-',)
          .gsub(':', '-')
          .gsub('?', '-')
          .gsub('&', '-')
          .gsub('=', '-')
          .gsub('.', '-')
      end

      def debug(value)
        puts('DEBUG: '.red + value.to_s)
        self
      end
    end
  end
end
