require 'pp'
require 'nokogiri'
require_relative '../error'

module HtmlReader
  module Page
    ##
    # This class responsible for getting values according to an instruction
    #
    # @see tests/html_reader/page/test_entity_fetcher.rb

    class ValuesCollector
      ##
      # Extra options
      #
      # @type [Hash]

      @options = {}

      ##
      # Collected data
      #
      # @type [Hash]

      @data    = {}

      def initialize(options = {})
        @options = options
        @data    = {}
      end

      ##
      # Fetch value of element
      #
      # @param [Symbol] name
      # @param [Hash] instruction
      # @param [Nokogiri::XML::Element] node
      # @return [String, Nokogiri::XML::Element]

      def fetch(name, instruction, node)
        if node && instruction[:type] == :attribute
          value = get_node_attribute(
            node,
            instruction
          )
        elsif instruction[:type] == :function
          value = call_function(name, instruction)
        elsif instruction[:type] == :children
          value = get_children(name, instruction, node)
        elsif node && (instruction[:type] == :value || nil == instruction[:type])
          # empty type should be determined as :value
          value = node
        elsif nil == node && instruction[:type]
          value = nil
        else
          raise HtmlReader::Error.new 'Unknown instruction type.'
        end

        value = filter_node(value, instruction)
        if @data[name].instance_of? Array and value.instance_of? Array
          @data[name] = [@data[name], value].flatten
        else
          unless @data[name].nil? and true != instruction[:overwrite]
            raise "Value already set for data key name '#{name}'."
          end
          @data[name] = value
        end

        @data[name]
      end

      ##
      # Get collected data
      #
      # @return [Hash]

      def get_data
        @data
      end

      protected

      ##
      # Fetch value of element
      #
      # @param [Symbol] name
      # @param [Hash] instruction
      # @param [Nokogiri::XML::Element] node
      # @return [self]

      def get_children(name, instruction, node)
        instruction = instruction[:instructions] == :the_same ?
          @options[:instructions] : instruction[:instructions]

        Page::EntityFetcher.new.
          set_instructions(instruction).
          fetch(document: node, plenty: true)
      end

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

      ##
      # Filter fetched node
      #
      # @param [Nokogiri::XML::Element] value
      # @param [Symbol] filter_name
      # @return [String, Nokogiri::XML::Element]

      def filter(value, filter_name = nil)
        # return as is, :filter can be omitted in instruction
        return value if filter_name == :element

        # return non-stripped text
        return value.text if filter_name == :no_strip

        # return text with tags
        return value.to_s.strip if filter_name == :node_text

        # return text without tags
        value.text.strip
      end

      ##
      # @param [Nokogiri::XML::Element] node
      # @param [Hash] instruction
      # @return [String]

      def get_node_attribute(node, instruction)
        node[instruction[:attribute]]
      end

      ##
      # Call custom function
      #
      # @param [Hash] instruction
      # @return [*]

      def call_function(name, instruction)
        if instruction[:function].instance_of? Proc
          instruction[:function].call name, instruction, @data, @options
        else
          HtmlReader::Error.new ':function is not instance of Proc'
        end
      end
    end
  end
end

