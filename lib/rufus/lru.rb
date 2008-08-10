#
#--
# Copyright (c) 2007-2008, John Mettraux, jmettraux@gmail.com
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
#++
#

#
# "made in Japan"
#
# John Mettraux
#

#require 'monitor'


#
# A Hash that has a max size. After the maxsize has been reached, the
# least recently used entries (LRU hence), will be discared to make
# room for the new entries.
#
#   require 'rubygems'
#   require 'rufus/lru'
#
#   h = LruHash.new 3
#
#   5.times { |i| h[i] = "a" * i }
#
#   puts h.inspect # >> {2=>"aa", 3=>"aaa", 4=>"aaaa"}
#
#   h[:newer] = "b"
#
#   puts h.inspect # >> {:newer=>"b", 3=>"aaa", 4=>"aaaa"}
#
#
class LruHash < Hash

  #--
  #include MonitorMixin
    #
    # seems not necessary for now, and it collides with expool's
    # @monitors own sync
  #++

  attr_reader :maxsize

  #
  # Initializes a LruHash with a given maxsize.
  #
  def initialize (maxsize)

    super()

    @maxsize = maxsize
    @lru_keys = []
  end

  def maxsize= (s)

    @maxsize = s
    remove_lru
  end

  def clear

    super
    @lru_keys.clear
  end

  #
  # Returns the keys with the lru in front.
  #
  def ordered_keys

    @lru_keys
  end

  def [] (key)

    value = super
    return nil unless value
    touch key

    value
  end

  def []= (key, value)

    remove_lru
    super
    touch key

    value
  end

  def merge! (hash)

    hash.each { |k, v| self[k] = v }

    # not using 'super', but in order not guaranteed at all...
  end

  def delete (key)

    value = super
    @lru_keys.delete key

    value
  end

  protected

    #
    # Puts the key on top of the lru 'stack'.
    # The bottom being the lru place.
    #
    def touch (key)

      @lru_keys.delete key
      @lru_keys << key
    end

    #
    # Makes sure that the hash fits its maxsize. If not, will remove
    # the least recently used items.
    #
    def remove_lru

      while size >= @maxsize

        key = @lru_keys.delete_at 0
        delete key
      end
    end
end

