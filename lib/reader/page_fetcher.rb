module Reader
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
  end
end
