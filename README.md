
# rufus-lru

LruHash class, a Hash with a max size, controlled by a LRU mechanism.


## getting it

```
gem install rufus-lru
```

or simply add to your ```Gemfile```

```
gem 'rufus-lru'
```


## usage

It's a regular hash, but you have to set a maxsize at instantiation.

Once the maxsize is reached, the hash will discard the element that was the
least recently used (hence LRU).

```ruby
require 'rubygems'
require 'rufus-lru'

h = Rufus::Lru::Hash.new(3)

5.times { |i| h[i] = "a" * i }

puts h.inspect # >> {2=>"aa", 3=>"aaa", 4=>"aaaa"}

h[:newer] = 'b'

puts h.inspect # >> {:newer=>"b", 3=>"aaa", 4=>"aaaa"}
```

Rufus::Lru::Hash isn't thread-safe, if you need something that is, use Rufus::Lru::SynchronizedHash

```ruby
require 'rubygems'
require 'rufus-lru'

h = Rufus::Lru::SynchronizedHash.new(3)

# ...
```

It's possible to squeeze LruHash manually:

```ruby
h = Rufus::Lru::Hash.new(33, true)
# or h.squeeze_on_demand=true
.
.
h.squeeze!
```

If a value has destructor method #clear it may be called upon the key-value expungement

```ruby
require 'rubygems'
require 'rufus-lru'

class ObjectWithDestructor; def clear ; puts 'Destructor called' ; end ; end

h = LruHash.new(1, false, true) # or h.clear_value_on_expungement=true after h is created
h[:one] = ObjectWithDestructor.new
h[:two] = nil                   # :one is being expunged >> "Destructor called"
```


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

John Mettraux, jmettraux@gmail.com, http://lambda.io/jmettraux


## contributors

Baldur Gudbjornsson - https://github.com/baldur


## the rest of Rufus

http://rufus.rubyforge.org


## license

MIT

