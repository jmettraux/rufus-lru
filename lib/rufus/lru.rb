#--
# Copyright (c) 2007-2012, John Mettraux, jmettraux@gmail.com
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
# "made in Japan"
#++

require 'thread'


module Rufus
module Lru

  VERSION = '1.0.5'

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
  # Nota bene: this class is not thread-safe. If you need something thread-safe,
  # use Rufus::Lru::SynchronizedHash.
  #
  class Hash < ::Hash

    attr_reader :maxsize
    attr_reader :lru_keys

    # Initializes a LruHash with a given maxsize.
    #
    def initialize(maxsize)

      super()

      @maxsize = maxsize
      @lru_keys = []
    end

    def maxsize=(i)

      @maxsize = i
      remove_lru

      i
    end

    def clear

      @lru_keys.clear

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

      remove_lru
      touch(key)

      super
    end

    def merge!(hash)

      hash.each { |k, v| self[k] = v }

      # not using 'super', but in order not guaranteed at all...
    end

    def delete(key)

      @lru_keys.delete(key)

      super
    end

    # Returns a regular Hash with the entries in this hash.
    #
    def to_h

      {}.merge!(self)
    end

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

    def initialize(maxsize)

      super
      @mutex = Mutex.new
    end

    def [](key)

      @mutex.synchronize { super }
    end

    def []=(key, value)

      @mutex.synchronize { super }
    end
  end
end
end


#
# The original LruHash class, kept for backward compatibility.
#
class LruHash < Rufus::Lru::Hash; end

