module Service
  module Bmovies
    module Api
      module Category
        ##
        # Module for getting one-level-sorted/linear menu
        #
        module MenuLinear
          protected

          def to_linear(menu, parent_name = '', level = 0, count = 0)
            result = {}
            menu.each do |item|
              return show item, level if item.instance_of? Array

              if level > 0
                count += 1
                result[count] = {
                  id: count,
                  label: parent_name.to_s + '/' + item[:label],
                  url: item[:url]
                }
              end

              next unless item[:_children]
              result = result.merge(
                to_linear(
                  item[:_children], item[:label], level + 1, result.count
                )
              )
            end
            result
          end
        end
      end
    end
  end
end
