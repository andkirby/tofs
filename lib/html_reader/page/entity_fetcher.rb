require 'pp'
require 'nokogiri'
require_relative '../error'
require_relative 'values_collector'

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
      #     :type     => :instruction,
      #     :selector => '.test-block a.deep-in',
      #   }
      # }
      # There are filters allowed for type :instruction :
      # - :node_text, returns XML of found node
      # - :node, returns object Nokogiri::XML::Element of found node
      # - :no_strip, returns non-stripped text
      # - by default it use .strip for found text
      # Example for calculating instruction according to fetch fields:
      # {
      #   :vote_up   => {
      #     :type     => :instruction,
      #     :selector => '.vote-up',
      #   },
      #     :vote_down => {
      #     :type     => :instruction,
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
        collector = get_values_collector(document)

        get_instructions.each { |instruction|
          node = instruction[:selector] ? fetch_node(document, instruction) : nil

          if instruction[:data]
            instruction[:data].each { |name, data_instruction|
              collector.fetch name, data_instruction, node
            }
          end
        }

        collector.get_data
      end

      # @param [Nokogiri::HTML::Document, Nokogiri::XML::Element] document
      # @return [Page::ValuesCollector]
      def get_values_collector(document)
        Page::ValuesCollector.new({:document => document})
      end

      ##
      # Fetch collection data from document
      #
      # @param [Nokogiri::HTML::Document, Nokogiri::XML::Element] document
      # @return [Hash]

      def fetch_plenty(document)
        collectors = {}
        get_instructions.each { |instruction|
          nodes = instruction[:selector] ? fetch_nodes(document, instruction) : nil

          nodes.each_with_index { |node, i|
            unless collectors.key? i
              collectors[i] = get_values_collector(document)
            end

            if instruction[:data]
              instruction[:data].each { |name, data_instruction|
                collectors[i].fetch name, data_instruction, node
              }
            end
          }
        }

        data = []
        # @param [Page::ValuesCollector] collection
        collectors.each { |i, collector|
          data.push collector.get_data
        }

        data
      end

      protected

      # region CSS getters

      ##
      # Get node by CSS selector
      #
      # @param [Nokogiri::HTML::Document] document
      # @param [Hash] instruction
      # @return [Nokogiri::XML::Element]

      def fetch_node(document, instruction)
        document.css(instruction[:selector]).first
      end

      ##
      # Get node by CSS selector
      #
      # @param [Nokogiri::HTML::Document] document
      # @param [Hash] instruction
      # @return [Nokogiri::XML::NodeSet]

      def fetch_nodes(document, instruction)
        if @selector_cache[instruction[:selector]]
          return @selector_cache[instruction[:selector]]
        end

        @selector_cache[instruction[:selector]] = document.css(instruction[:selector])
      end

      # endregion
    end
  end
end

