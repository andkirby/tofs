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
      find_entities(document).each { |entity_document|
        items.unshift fetch_entity_data(entity_document)
      }
      items
    end

    ##
    # Fetch entity data
    #
    # @param [Nokogiri::XML::Element] entity_document
    # @return [Hash]

    def fetch_entity_data(entity_document)
      fetcher = Page::EntityFetcher.new
      fetcher.set_instructions get_instructions[:entity][:instructions]
      fetcher.fetch entity_document
    end


    ##
    # Fetch entities on a page
    #
    # @param [Nokogiri::HTML::Document] document
    # @return [Nokogiri::XML::Element[]]

    def find_entities(document)
      if get_instructions[:entity][:type] == :function
        return call_function(document, get_instructions[:entity])
      end
      document.css(get_instructions[:entity][:selector])
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
        document.css(get_instructions[:last_page][:selector]).count > 0
      end

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
