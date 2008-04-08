
= rufus-lru

LruHash class, a Hash with a max size, controlled by a LRU mechanism


== getting it

    sudo gem install rufus-lru

or at

http://rubyforge.org/frs/?group_id=4812


== usage

It's a regular hash, but you have to set a maxsize at instantiation.

Once the maxsize is reached, the hash will discard the element that was the
least recently used (hence LRU).

    require 'rubygems'
    require 'rufus/lru'

    h = LruHash.new 3

    5.times { |i| h[i] = "a" * i }

    puts h.inspect # >> {2=>"aa", 3=>"aaa", 4=>"aaaa"}

    h[:newer] = "b"

    puts h.inspect # >> {:newer=>"b", 3=>"aaa", 4=>"aaaa"}


== dependencies

None.


== mailing list

On the rufus-ruby list[http://groups.google.com/group/rufus-ruby] :

    http://groups.google.com/group/rufus-ruby


== issue tracker

http://rubyforge.org/tracker/?atid=18584&group_id=4812&func=browse


== source

http://github.com/jmettraux/rufus-lru

    git clone git://github.com/jmettraux/rufus-lru.git


== author

John Mettraux, jmettraux@gmail.com 
http://jmettraux.wordpress.com


== the rest of Rufus

http://rufus.rubyforge.org


== license

MIT

