module Shell
  # Output
  # This class helps to make output message for command line
  module Output
    @last_firm_message
    @last_message_inline
    @last_message_length

    # Add simple output
    #
    # @param {String} message
    def simple(message)
      add message, false, false
      self
    end

    # Add inline output
    # Next line will be added after this line
    #
    # @param {String} message
    def inline(message)
      add message, false, true
      self
    end

    # Add temporary output
    # Next line will erase this line
    #
    # @param {String} message
    def temp(message)
      add message, true, true
      self
    end

    # Add inline output
    # Next line will be added after this line
    #
    # @param [String] message
    # @param [Boolean] replaceable Passed message should be replaced with next line
    # @param [Boolean] inline      Passed message should be added inline,
    #                             i.e. without line separator
    def add(message, replaceable = false, inline = false)
      # Go to next line if it's not inline
      print "\n" if !inline && @last_message_inline

      if @last_firm_message && replaceable
        print (replaceable ? "\r" : '')
        print @last_firm_message + message + (' ' * @last_message_length.to_i)
      else
        print message + (' ' * @last_message_length.to_i)
      end

      print (replaceable ? "\r" : '')
      print (!replaceable && !inline ? "\n" : '')

      # it's needed for full replacement with spaces of previous message
      @last_message_length = replaceable ? message.length : 0
      # save last firm message for replacement
      @last_firm_message = message if !replaceable && inline
      # save last inline state for pushing next non-inline message to the next line
      @last_message_inline = inline

      flash_output
      self
    end

    protected

    def flash_output
      STDOUT.flush
      self
    end

    module_function :simple, :inline, :temp, :flash_output, :add
  end
end
