
# rufus-lru

LruHash class, a Hash with a max size, controlled by a LRU mechanism.


## getting it

    gem install rufus-lru


## usage

It's a regular hash, but you have to set a maxsize at instantiation.

Once the maxsize is reached, the hash will discard the element that was the
least recently used (hence LRU).

    require 'rubygems'
    require 'rufus-lru'

    h = Rufus::Lru::Hash.new(3)

    5.times { |i| h[i] = "a" * i }

    puts h.inspect # >> {2=>"aa", 3=>"aaa", 4=>"aaaa"}

    h[:newer] = 'b'

    puts h.inspect # >> {:newer=>"b", 3=>"aaa", 4=>"aaaa"}

Rufus::Lru::Hash isn't thread-safe, if you need something that is, use Rufus::Lru::SynchronizedHash

    require 'rubygems'
    require 'rufus-lru'

    h = Rufus::Lru::SyncrhonizedHash.new(3)

    # ...


## dependencies

None.


## mailing list

On the rufus-ruby list:

http://groups.google.com/group/rufus-ruby


## issue tracker

http://github.com/jmettraux/rufus-lru/issues


## irc

irc.freenode.net #ruote


## source

http://github.com/jmettraux/rufus-lru

    git clone git://github.com/jmettraux/rufus-lru.git


## author

John Mettraux, jmettraux@gmail.com
http://jmettraux.wordpress.com


## the rest of Rufus

http://rufus.rubyforge.org


## license

MIT

