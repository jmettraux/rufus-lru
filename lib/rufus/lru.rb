#--
# Copyright (c) 2007-2014, John Mettraux, jmettraux@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# "Made in Japan"
#++

require 'thread'


module Rufus
module Lru

  VERSION = '1.0.6'

  #
  # A Hash that has a max size. After the maxsize has been reached, the
  # least recently used entries (LRU hence), will be discared to make
  # room for the new entries.
  #
  #   require 'rubygems'
  #   require 'rufus/lru'
  #
  #   h = LruHash.new(3)
  #
  #   5.times { |i| h[i] = "a" * i }
  #
  #   puts h.inspect # >> {2=>"aa", 3=>"aaa", 4=>"aaaa"}
  #
  #   h[:newer] = "b"
  #
  #   puts h.inspect # >> {:newer=>"b", 3=>"aaa", 4=>"aaaa"}
  #
  # One may want to squeeze hash manually
  #
  #   h = LruHash.new(3, true)
  #   # or h.squeeze_on_demand=true after h is created
  #   .
  #   .
  #   h.squeeze!
  #
  # If a value has destructor method #clear it may be called upon the
  # key-value removal
  #
  #   h = LruHash.new(33, does_not_matter, true)
  #   # or h.clear_value_on_removal=true after h is created
  #
  # Nota bene: this class is not thread-safe. If you need something thread-safe,
  # use Rufus::Lru::SynchronizedHash.
  #
  class Hash < ::Hash

    attr_reader :maxsize
    attr_reader :lru_keys
    attr_accessor :clear_value_on_removal

    # Initializes a LruHash with a given maxsize.
    #
    def initialize(maxsize, squeeze_on_demand = false, clear_value_on_removal = false)

      super()

      @maxsize = maxsize
      @lru_keys = []
      @squeeze_on_demand = squeeze_on_demand
      @clear_value_on_removal = clear_value_on_removal
    end

    def maxsize=(i)

      @maxsize = i
      squeeze! unless @squeeze_on_demand

      i
    end

    def squeeze_on_demand=(i)

      squeeze! if @squeeze_on_demand && !i
      @squeeze_on_demand = i

    end

    def squeeze_on_demand?

      @squeeze_on_demand
    end

    def clear

      @lru_keys.clear

      self.each_value { |value|
        value.clear if value.respond_to?(:clear)
      } if @clear_value_on_removal

      super
    end

    # Returns the keys with the lru in front.
    #
    alias ordered_keys lru_keys

    def [](key)

      return nil unless has_key?(key)

      touch(key)

      super
    end

    def []=(key, value)

      remove_lru unless @squeeze_on_demand
      touch(key)

      super
    end

    def merge!(hash)

      hash.each { |k, v| self[k] = v }

      # not using 'super', but in order not guaranteed at all...
    end

    def delete(key)

      if @clear_value_on_removal
        value = self.fetch(key)
        value.clear if value.respond_to?(:clear)
      end

      @lru_keys.delete(key)

      super
    end

    # Returns a regular Hash with the entries in this hash.
    #
    def to_h

      {}.merge!(self)
    end

    # public alias to remove_lru
    def squeeze! ; remove_lru ; end

    protected

    # Puts the key on top of the lru 'stack'.
    # The bottom being the lru place.
    #
    def touch(key)

      @lru_keys.delete(key)
      @lru_keys << key
    end

    # Makes sure that the hash fits its maxsize. If not, will remove
    # the least recently used items.
    #
    def remove_lru

      while size >= @maxsize
        delete(@lru_keys.delete_at(0))
      end
    end
  end

  #
  # A thread-safe version of the lru hash.
  #
  class SynchronizedHash < Hash

    def initialize(maxsize, squeeze_on_demand = false)

      super
      @mutex = Mutex.new
    end

    def [](key)

      @mutex.synchronize { super }
    end

    def []=(key, value)

      @mutex.synchronize { super }
    end

    def squeeze!

      @mutex.synchronize { super }
    end
  end
end
end


#
# The original LruHash class, kept for backward compatibility.
#
class LruHash < Rufus::Lru::Hash; end

