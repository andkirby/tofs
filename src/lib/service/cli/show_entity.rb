require 'terminal-table'
require 'word_wrap'
require 'colorize'

module Service
  module Cli
    module ShowEntity
      module_function

      VIEW_SHORT    = :short
      VIEW_NORMAL   = :normal
      VIEW_DETAILED = :detailed

      @keys_set = {
          VIEW_NORMAL => [:label, :seasons, :genre, :country, :'last episode'],
          VIEW_SHORT  => [:label, :seasons, :last_episode]
      }

      ##
      # Show entity data
      # TODO refactor this method (some blocks can be extracted)
      #
      def show_entity(entity, name: nil, max_width: nil, view: VIEW_SHORT)
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
          if @keys_set[view] and !@keys_set[view].include? key
            next
          end

          if [true, false].include? value
            value = value.to_s
          end

          if value.kind_of? Hash
            value = value[:label]
          end

          # gather names from array list
          if key == :seasons
            value = format_seasons(value, view: view)
          end


          # gather names from array list
          if value.kind_of? Array and value.first.kind_of? Hash and !value.first[:label].nil?
            value = value.collect {|h| h[:label]}.join(', ').to_s
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

          rows.push [key.to_s.gsub('_', ' ').capitalize.yellow, value.strip]
        end

        table = table(rows, max_width: max_width, name: name)

        show(table)
      end

      protected

      module_function

      def format_seasons(value, view: VIEW_SHORT)
        if view == VIEW_SHORT
          formatted = value.map do |v|
            output = v[:number]
            if v[:episodes]
              output += 'x' + v[:episodes].last[:number]
            end
            output
          end.join(", ").strip
        elsif view == VIEW_NORMAL
          formatted = value.map do |v|
            output = 'S' + v[:number]
            if v[:episodes]
              output += ' (last: E' + v[:episodes].last[:number] + ')'
            end
            output
          end.join("\n").strip
        else
          formatted = ''
          value.each do |season|
            formatted += "\nS#{season[:number]}"
            if season[:episodes]
              season[:episodes].each do |episode|
                formatted += "\n- E#{episode[:number]} #{episode[:quality]}" +
                    " #{episode[:label]}"
              end
            end
          end
        end
        formatted.strip
      end


      def show(table)
        puts table
      end


      def terminal_columns
        HighLine::SystemExtensions.terminal_size.first
      end

      def table(rows, max_width:, name: nil)
        table = Terminal::Table.new title: name,
                                    rows:  rows, style: {:width => max_width}
        table.align_column(0, :right)
        table
      end
    end
  end
end
