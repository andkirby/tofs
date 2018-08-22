require 'terminal-table'
require 'word_wrap'
require 'colorize'

module Service
  module Cli
    module ShowEntity
      module_function

      ##
      # Show entity data
      def show_entity(entity, name: nil, max_value_with: 100, max_width: 120)
        rows = []
        entity.each do |key, value|
          if value.kind_of? Hash
            value = value[:label]
          end
          if value.kind_of? Array and value.first.kind_of? Hash and !value.first[:label].nil?
            value = value.collect {|h| h[:label]}.join(", ").to_s
          end
          # words wrap, max 80 symbols
          value = WordWrap.ww value, max_value_with
          rows.push [key.to_s.capitalize.yellow, value]
        end

        table = Terminal::Table.new :title => name, :rows => rows, style: {:padding_left => 2, :width => max_width}

        puts table
      end
    end
  end
end
