#!/usr/bin/env ruby

require_relative 'lib/service/put_locker/cli/command_point'

module Service
  module PutLocker
    module Cli
      CommandPoint.new.run if $0 == __FILE__
    end
  end
end

