module HtmlReader
  module Page
    ##
    # Get node by XPath or CSS selector
    #
    # @param [Nokogiri::HTML::Document] document
    # @param [Hash] instruction
    # @return [Nokogiri::XML::Element]

    def fetch_node(document, instruction)
      nodes = fetch_nodes(document, instruction)
      nodes.first if nodes
    end

    ##
    # Get nodes by XPath or CSS selector
    #
    # @param [Nokogiri::HTML::Document] document
    # @param [Hash] instruction
    # @return [Nokogiri::XML::NodeSet]

    def fetch_nodes(document, instruction)
      if instruction[:selector]
        document.css(instruction[:selector])
      elsif instruction[:xpath]
        document.xpath(instruction[:xpath])
      end
    end

    module_function :fetch_nodes, :fetch_node
  end
end
