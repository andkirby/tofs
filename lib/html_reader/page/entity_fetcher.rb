require 'pp'
require 'nokogiri'
require_relative '../error'

module HtmlReader
  module Page
    ##
    # This entity-html_reader class designed for reading data from HTML/XML block according to instructions
    #
    # @see tests/html_reader/page/test_entity_fetcher.rb

    class EntityFetcher
      ##
      # Cache fetched XML elements
      # @type [Hash]

      @selector_cache = {}

      ##
      # Init

      def initialize
        @selector_cache = @selector_cache || {}
      end

      ##
      # Set instructions
      #
      # Example for reading simple text by CSS selector:
      # {
      #   :name1 => {
      #     :type     => :value,
      #     :selector => '.test-block a.deep-in',
      #   }
      # }
      # There are filters allowed for type :value :
      # - :node_text, returns XML of found node
      # - :node, returns object Nokogiri::XML::Element of found node
      # - :no_strip, returns non-stripped text
      # - by default it use .strip for found text
      # Example for calculating value according to fetch fields:
      # {
      #   :vote_up   => {
      #     :type     => :value,
      #     :selector => '.vote-up',
      #   },
      #     :vote_down => {
      #     :type     => :value,
      #     :selector => '.vote-down',
      #   },
      #     :vote_diff => {
      #     :type     => :function,
      #     :function => Proc.new { |info, name, document, instruction|
      #       info[:vote_up].to_i - info[:vote_down].to_i
      #     },
      #   }
      # }
      #
      # @param [Hash] instructions
      # @return [self]

      def set_instructions(instructions)
        @instructions = instructions
        self
      end

      # Get instructions
      #
      # @return [Hash]

      def get_instructions
        @instructions
      end

      ##
      # Fetch data from document
      #
      # @param [Nokogiri::HTML::Document, Nokogiri::XML::Element] document
      # @param [TrueClass, FalseClass] plenty Get plenty of elements or the only one
      # @return [Hash]

      def fetch(document, plenty = false)
        if plenty
          fetch_plenty(document)
        else
          fetch_single(document)
        end
      end

      ##
      # Fetch single data from document
      #
      # @param [Nokogiri::HTML::Document, Nokogiri::XML::Element] document
      # @return [Hash]

      def fetch_single(document)
        info = {}
        get_instructions.each { |name, instruction|
          instruction[:info] = info
          if instruction[:type] == :value
            node = fetch_node(document, instruction)
          elsif instruction[:type] == :attribute
            node = get_node_attribute(
              fetch_node(document, instruction),
              instruction
            )
          elsif instruction[:type] == :function
            node = call_function(info, name, document, instruction)
          else
            raise HtmlReader::Error.new 'Unknown instruction type.'
          end

          node       = filter_node(node, instruction)
          info[name] = node
        }
        info
      end

      ##
      # Fetch collection data from document
      #
      # @param [Nokogiri::HTML::Document, Nokogiri::XML::Element] document
      # @return [Hash]

      def fetch_plenty(document)
        info = {}
        get_instructions.each { |name, instruction|
          instruction[:info] = info
          if instruction[:type] == :value || instruction[:type] == :attribute
            nodes = get_nodes(document, instruction)
            if instruction[:type] == :attribute
              nodes = nodes.map {|node| get_node_attribute(node, instruction)}
            end
          elsif instruction[:type] == :function
            nodes = call_function(info, name, document, instruction)
          else
            raise HtmlReader::Error.new 'Unknown instruction type.'
          end

          nodes = nodes.map {|node| filter_node(node, instruction)}
          nodes.each_with_index { |node, i|
            info[i] = info[i] || {}; info[i][name] = node
          }
        }

        # Return without particular indexes
        info.map {|element| element[1]}
      end

      protected

      # region CSS getters

      ##
      # Filter node
      #
      # @param [Nokogiri::XML::Element] node
      # @param [Hash] instruction
      # @return [String, Nokogiri::XML::Element]

      def filter_node(node, instruction)
        if node.instance_of?(Nokogiri::XML::Element)
          node = filter(node, instruction[:filter])
        end
        node
      end

      # region CSS getters

      ##
      # Call custom function
      #
      # @param [Hash] info
      # @param [Symbol] name
      # @param [Nokogiri::HTML::Document] document
      # @param [Hash] instruction
      # @return [*]

      def call_function(info, name, document, instruction)
        instruction[:function].call info, name, document, instruction
      end

      ##
      # Get node by CSS selector
      #
      # @param [Nokogiri::HTML::Document] document
      # @param [Hash] instruction
      # @return [String]

      def fetch_node(document, instruction)
        document.css(instruction[:selector]).first
      end

      ##
      # Get node by CSS selector
      #
      # @param [Nokogiri::HTML::Document] document
      # @param [Hash] instruction
      # @return [Nokogiri::XML::NodeSet]

      def get_nodes(document, instruction)
        if @selector_cache[instruction[:selector]]
          return @selector_cache[instruction[:selector]]
        end

        @selector_cache[instruction[:selector]] = document.css(instruction[:selector])
      end

      ##
      # @param [Nokogiri::XML::Element] element
      # @param [Hash] instruction
      # @return [String]

      def get_node_attribute(element, instruction)
        element[instruction[:attribute]]
      end

      # endregion

      ##
      # Filter fetched node
      #
      # @param [Nokogiri::XML::Element] value
      # @param [Symbol] filter_name
      # @return [String, Nokogiri::XML::Element]

      def filter(value, filter_name = nil)
        # return as is
        return value if filter_name == :element

        # return non-stripped text
        return value.text if filter_name == :no_strip

        # return text with tags
        return value.to_s if filter_name == :node_text

        # return text without tags
        value.text.strip
      end
    end
  end
end

