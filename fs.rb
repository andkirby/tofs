require 'pp'
require_relative 'lib/service/fs2_ua/api/category/genres'

result = Service::Fs2Ua::Api::Category::Genres.new.fetch
pp result
result.each_with_index {|i, element|
  pp element
  pp i
  exit 2
}
