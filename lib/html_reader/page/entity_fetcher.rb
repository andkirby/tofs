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
      # - :element, returns object Nokogiri::XML::Element of found node
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
      # @return [Hash]

      def fetch(document)
        info = {}
        get_instructions.each { |name, instruction|
          instruction[:info] = info
          if instruction[:type] == :value
            info[name] = get_node(document, instruction)
          elsif instruction[:type] == :attribute
            info[name] = get_node_attribute(document, instruction)
          elsif instruction[:type] == :function
            info[name] = call_function(info, name, document, instruction)
          else
            raise HtmlReader::Error.new 'Unknown instruction type.'
          end

          if info[name].instance_of?(Nokogiri::XML::Element)
            info[name] = filter(info[name], instruction[:filter])
          end
        }
        info
      end

      protected

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

      def get_node(document, instruction)
        document.css(instruction[:selector]).first
      end

      ##
      # @param [Nokogiri::HTML::Document] document
      # @param [Hash] instruction
      # @return [String]

      def get_node_attribute(document, instruction)
        get_node(document, instruction)[instruction[:attribute]]
      end

      # endregion

      ##
      # Filter fetched element
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

