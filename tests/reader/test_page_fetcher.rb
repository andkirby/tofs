require 'test/unit'
require 'mocha/test_unit'
require 'nokogiri'
require_relative '../../lib/reader/page_fetcher'

module Reader
  class TestPage < Test::Unit::TestCase
    # Test get/set instructions
    def test_set_instructions
      obj   = PageFetcher.new
      value = {:aa => 'aa'}
      assert_instance_of(PageFetcher, obj.set_instructions(value))
      assert_equal(value, obj.get_instructions)
    end
  end
end
