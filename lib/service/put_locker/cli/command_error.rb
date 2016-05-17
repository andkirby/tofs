require 'commander'

# Error class for exceptions
module Service
  module PutLocker
    module Cli
      class CommandError < Commander::Runner::CommandError
      end
    end
  end
end
