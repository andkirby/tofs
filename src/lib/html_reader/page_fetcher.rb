require_relative 'page/entity_fetcher'

module HtmlReader
  class PageFetcher
    ##
    # Set instructions
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

    # Fetch entities from document
    #
    # @param [Nokogiri::HTML::Document] document
    # @return [Hash]

    def fetch(document)
      items = []
      fetch_block_document(document, get_instructions[:block]).each { |block_document|
        fetch_data(block_document, get_instructions[:entity]).each { |element|
          items.push element
        }
      }
      items
    end

    ##
    # Check if it's a last page
    #
    # @param [Nokogiri::HTML::Document] document
    # @return [TrueClass, FalseClass]

    def last_page?(document)
      if get_instructions[:last_page][:type] == :function
        !!call_function(document, get_instructions[:last_page])
      else
        Page::fetch_nodes(document, get_instructions[:last_page]).count > 0
      end
    end

    protected

    ##
    # Fetch entity data
    #
    # @param [Nokogiri::XML::Element] entity_document
    # @param [Hash] instructions
    # @return [Hash]

    def fetch_data(entity_document, instructions)
      fetcher = Page::EntityFetcher.new
      fetcher.set_instructions instructions
      fetcher.fetch(document: entity_document, plenty: true)
    end

    ##
    # Fetch entities on a page
    #
    # @param [Nokogiri::HTML::Document] document
    # @return [Nokogiri::XML::NodeSet]

    def fetch_block_document(document, instructions)
      if instructions[:type] == :function
        return call_function(document, instructions)
      end
      Page::fetch_nodes(document, instructions)
    end

    ##
    # Call custom function
    #
    # @param [Nokogiri::HTML::Document] document
    # @param [Hash] instruction
    # @return [*]

    def call_function(document, instruction)
      instruction[:function].call document, instruction
    end
  end
end
