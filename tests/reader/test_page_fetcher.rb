require 'test/unit'
require 'mocha/test_unit'
require 'nokogiri'
require 'pp'
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

    # Test fetching nodes on a page
    def test_fetch_page_nodes
      obj  = PageFetcher.new
      html = Nokogiri::HTML(get_content)
      obj.set_instructions(
        {
          :entity    => {
            :type         => :selector,
            :selector     => '.blocks .nodes',
            # Instructions for entity which will be use in EntityFetcher
            :instructions => {
              :my_item => {
                :type     => :value,
                :selector => 'span.item-text',
              }
            },
          },
          :last_page => {
            :type     => :selector,
            :selector => '.pager > span.active:last',
          },
        })
      # todo mock using EntityFetcher class
      assert_equal(
        [{:my_item => 'b2'}, {:my_item => 'b1'},
         {:my_item => 'a2'}, {:my_item => 'a1'}],
        obj.fetch(html))
    end

    protected

    def get_content
      <<-html
<div class="blocks block-a">
  <div class="nodes node1">
    <span class="item-text">a1</span>
  </div>
  <div class="nodes node2">
    <span class="item-text">a2</span>
  </div>
</div>
<div class="blocks block-b">
  <div class="nodes node1">
    <span class="item-text">b1</span>
  </div>
  <div class="nodes node2">
    <span class="item-text">b2</span>
  </div>
</div>
<div class="pager">
  <span class="item">page 1</span>
  <span class="item active">page 2</span>
</div>
      html
    end
  end
end
