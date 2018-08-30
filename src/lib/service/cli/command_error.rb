require 'commander'

# Error class for exceptions
module Service
  module Cli
    class CommandError < Commander::Runner::CommandError
    end
  end
end
