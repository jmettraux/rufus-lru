
require 'spec_helper'


describe Rufus::Lru::Hash do

  let(:hash) { Rufus::Lru::Hash.new(3) }

  context 'like a ::Hash' do

    it 'supports insertion' do

      hash[1] = 2

      hash[1].should == 2
    end

    it 'supports deletion' do

      hash[1] = 2

      hash.delete(1).should == 2

      hash.size.should == 0
    end
  end

  context 'as a LRU Hash' do

    it 'drops entries when the maxsize is reached' do

      4.times { |i| hash[i] = i }

      hash.size.should == 3
    end

    it 're-inserting under a key places the key at the end of the lru_keys' do

      3.times { |i| hash[i] = i }

      hash[0] = :new

      hash.lru_keys.should == [ 1, 2, 0 ]
    end

    it 'removes keys from the lru_keys upon entry deletion' do

      hash[1] = 1
      hash.delete(1)

      hash.lru_keys.should == []
    end
  end

  describe '#lru_keys' do

    it 'returns the keys with the least recently used first' do

      3.times { |i| hash[i] = i }

      hash.lru_keys.should == [ 0, 1, 2 ]
    end
  end

  describe '#ordered_keys' do

    it 'is an alias for #lru_keys' do

      3.times { |i| hash[i] = i }

      hash.lru_keys.should == [ 0, 1, 2 ]
    end
  end

  describe '#[]' do

    it 'returns nil if there is no value' do

      hash[:x].should == nil
    end

    it 'returns false when the value is false' do

      hash[1] = false

      hash[1].should == false
    end

    it 'does not modify the LRU list when looking up a non-present key' do

      hash[:x]

      hash.lru_keys.should == []
    end

    it 'returns the current value' do

      hash[1] = 2

      hash[1].should == 2
    end
  end

  describe '#merge!' do

    it 'merges in place' do

      hash.merge!(1 => 1, 2 => 2)

      hash.size.should == 2
      hash.lru_keys.sort.should == [ 1, 2 ]
    end
  end

  describe '#to_h' do

    it 'returns a new hash with the entries of the LRU hash' do

      4.times { |i| hash[i] = i }

      hash.to_h.class.should == ::Hash
      hash.to_h.should == { 1 => 1, 2 => 2, 3 => 3 }
    end
  end

  describe '#auto_squeeze?' do

    it 'returns true by default' do

      hash.auto_squeeze?.should == true
    end
  end

  describe '#auto_squeeze=' do

    it 'sets the auto_squeeze behaviour' do

      hash.auto_squeeze = false
      hash.auto_squeeze?.should == false

      hash.auto_squeeze = true
      hash.auto_squeeze?.should == true
    end

    it 'squeezes when passed true' do

      hash.auto_squeeze = false

      5.times { |i| hash[i] = i }
      hash.size.should == 5

      hash.auto_squeeze = true
      hash.size.should == 2
    end
  end

  describe '#squeeze!' do

    it 'squeezes' do

      hash.auto_squeeze = false

      5.times { |i| hash[i] = i }
      hash.size.should == 5

      hash.squeeze!
      hash.size.should == 2
    end
  end

  describe '#on_removal=' do

    it 'accepts a Symbol (name of the meth to call on the just removed values)' do

      hash.on_removal = :clear
      destructor_was_called = 0

      value = 'nada'
      (class << value; self; end).send(
        :define_method, :clear, lambda { destructor_was_called += 1 })

      5.times { |i| hash[i] = value }
      destructor_was_called.should == 2

      hash.delete 4
      destructor_was_called.should == 3

      hash.clear
      destructor_was_called.should == 5
    end

    it 'accepts a lambda (to be called each time a value is removed)' do

      destroyed = []
      hash.on_removal = lambda { |val| destroyed << val }

      5.times { |i| hash[i] = "item#{i}" }
      destroyed.should == %w[ item0 item1 ]

      hash.delete(4)
      destroyed.should == %w[ item0 item1 item4 ]

      hash.clear
      destroyed.should == %w[ item0 item1 item4 item2 item3 ]
    end
  end
end

