require 'terminal-table'
require 'word_wrap'
require 'colorize'

module Service
  module Cli
    module ShowEntity
      module_function

      ##
      # Show entity data
      # TODO refactor this method (some blocks can be extracted)
      #
      def show_entity(entity, name: nil, max_width: nil)
        # Hash keys max width
        key_column_width = entity.max_by {|k, v| k.length}.first.length
        max_width        = terminal_columns if !max_width or
            max_width > terminal_columns

        # check max "value" column width has
        # 7= 2 (1st col padding) + 2 (2st col padding) +
        #    3 table pipes + 1 for a space
        max_value_width = max_width - key_column_width - 8

        rows = []
        entity.each do |key, value|
          if value.kind_of? Hash
            value = value[:label]
          end

          # gather names from array list
          if value.kind_of? Array and value.first.kind_of? Hash and !value.first[:label].nil?
            value = value.collect {|h| h[:label]}.join(", ").to_s
          end

          # wrap value
          if value.index ' '
            value = WordWrap.ww value, max_value_width
          elsif value.length > max_value_width
            # insert line delimiters into non-spaced string
            (value.length / max_value_width).to_i.times do |i|
              value.insert((i + 1) * max_value_width + i, "\n")
            end
          end

          rows.push [key.to_s.capitalize.yellow, value.strip]
        end

        table = Terminal::Table.new title: name,
                                    rows:  rows, style: {:width => max_width}
        table.align_column(0, :right)

        puts table
      end

      protected

      module_function

      def terminal_columns
        HighLine::SystemExtensions.terminal_size.first
      end
    end
  end
end
