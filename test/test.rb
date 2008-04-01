
#
# Testing rufus-lru
#
# jmettraux@gmail.com
#
#      Sun Oct 29 16:18:25 JST 2006
# then Tue Jan 15 12:53:04 JST 2008
#

require 'test/unit'
require 'rufus/lru'


class LruTest < Test::Unit::TestCase

    #def setup
    #end

    #def teardown
    #end

    def test_0

        h = LruHash.new 3

        assert_equal 0, h.size

        h[:a] = "A"

        assert_equal 1, h.size

        h[:b] = "B"
        h[:c] = "C"

        assert_equal [ :a, :b, :c ], h.ordered_keys

        h[:d] = "D"

        assert_equal 3, h.size
        assert_equal [ :b, :c, :d ], h.ordered_keys
        assert_equal nil, h[:a]
        assert_equal "B", h[:b]
        assert_equal [ :c, :d, :b ], h.ordered_keys

        h.delete :d

        #require 'pp'
        #puts "lru keys :"
        #pp h.ordered_keys

        assert_equal 2, h.size
        assert_equal [ :c, :b ], h.ordered_keys

        h[:a] = "A"

        assert_equal 3, h.size
        assert_equal [ :c, :b, :a ], h.ordered_keys

        h[:d] = "D"


        assert_equal 3, h.size
        assert_equal [ :b, :a, :d ], h.ordered_keys

        assert_equal "B", h[:b]
        assert_equal "A", h[:a]
        assert_equal "D", h[:d]
        assert_equal nil, h[:c]
        assert_equal [ :b, :a, :d ], h.ordered_keys
    end

    def test_1

        h = LruHash.new 3

        h[1] = 10

        h.merge!({ 2 => 20, 3 => 30, 4 => 40, 5 => 50 })

        assert_nil h[1]
        assert_equal 3, h.size
    end

end
