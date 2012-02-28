
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
end

