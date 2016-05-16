require 'commander'

module Service
  module PutLocker
    module Cli
      class CommandError < Commander::Runner::CommandError
      end
    end
  end
end
