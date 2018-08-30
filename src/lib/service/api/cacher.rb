require 'timedcache'

module Service
  module Api
    # Cache adapter
    class Cacher
      @cache_dir     = nil
      @adapters      = nil
      @base_name     = nil
      @use_base_name = nil
      @timeout       = nil
      @debug         = false

      # Init options
      #
      # @param [Hash] input_options
      #
      def initialize(input_options = {})
        self.options = input_options
        require 'colorize' if @debug
        debug_initialize if @debug
      end

      ##
      # Get cacher
      #
      # @param [String] namespace
      # @return [TimedCache]
      #
      def adapter(namespace = nil)
        namespace = @default_namespace if namespace.nil?

        return @adapters[namespace] if @adapters[namespace]

        file            = cache_file(namespace, @use_base_name)
        @adapters[file] = TimedCache.new(
          type: 'file', filename: file, default_timeout: @timeout
        )
      end

      ##
      # Read cache
      #
      # @param [String] key
      # @param [String] namespace
      # @return [string]
      #
      def get(key, namespace = nil)
        # debug
        if @debug
          debug(__method__.to_s.cyan + ' key:'.yellow + " #{key}, " +
                  'ns:'.yellow + ' ' +
                  (namespace || @default_namespace).to_s)
        end

        adapter(namespace).get(key)
      end

      ##
      # Write cache
      #
      # @param [String] key
      # @param [String, NilClass] namespace
      # @param [Integer, NilClass] timeout
      # @return [string]
      #
      def put(key, value, namespace = nil, timeout = nil)
        timeout = adapter(namespace).default_timeout if timeout.nil?

        # debug
        debug_put(key, namespace, timeout) if @debug

        adapter(namespace).put(key, value, timeout)
        self
      end

      protected

      def debug_put(key, namespace, timeout)
        debug "
#{__method__.to_s.cyan}
#{'key:'.yellow} #{key}, #{'ns:'.yellow}
#{(namespace || @default_namespace)}
#{'timeout:'.yellow} #{timeout}".tr("\n", ' ')
      end

      ##
      # Get cache file
      #
      # @param [String] namespace
      # @param [TrueClass FalseClass] use_base_name
      # @return [string]
      #
      def cache_file(namespace, use_base_name)
        file = @cache_dir + '/' +
               (use_base_name ? base_cache_key + '/' : '') +
               (namespace ? safe_name(namespace) : 'main') + '.txt'
        # TODO: Check writing
        FileUtils.mkpath File.dirname(file)
        file
      end

      ##
      # Get base cache key
      #
      # @return [String]
      #
      def base_cache_key
        return @base_cache_key if @base_cache_key
        @base_cache_key = safe_name(@base_name)
      end

      ##
      # Make safe string
      #
      # @return [String]
      #
      def safe_name(name)
        raise "It's not a string." unless name.instance_of? String

        name.tr('/', '-')
            .tr(':', '-')
            .tr('?', '-')
            .tr('&', '-')
            .tr('=', '-')
            .tr('.', '-')
      end

      def debug(value)
        puts('DEBUG: '.red + value.to_s)
        self
      end

      def options=(options)
        @base_name         = options[:base_name]
        @default_namespace = options[:default_namespace]
        @timeout           = options[:timeout] || 24 * 3600 * 365
        @cache_dir         = options[:cache_dir] || '/tmp/cached-request-ruby'
        @use_base_name     =
          options.key?(:use_base_name) ? options[:use_base_name] : true
        @adapters          = {}
        @debug             = !!options[:debug]
      end

      def debug_initialize
        debug '@base_name '.yellow + @base_name
        debug '@timeout '.yellow + @timeout.to_s
        debug '@cache_dir '.yellow + @cache_dir
        debug '@default_namespace '.yellow + @default_namespace.to_s
      end
    end
  end
end
