module Service
  module Bmovies
    module Api
      module Category
        module MenuLinear
          protected

          def to_linear(menu, parent_name = '', level = 0, count = 0)
            result = {}
            menu.each {|item|
              if item.instance_of? Array
                return show item, level
              end

              if level > 0
                count += 1
                result[count] = {
                    :id => count,
                    :label => parent_name.to_s + '/' + item[:label],
                    :url => item[:url]
                }
              end

              if item[:_children]
                result = result.merge(
                    to_linear(
                        item[:_children], item[:label], level + 1, result.count
                    )
                )
              end
            }
            result
          end
        end
      end
    end
  end
end
