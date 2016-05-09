
require 'spec_helper'


describe Rufus::Lru::Hash do

  let(:hash) { Rufus::Lru::Hash.new(3) }

  context 'like a ::Hash' do

    it 'supports insertion' do

      hash[1] = 2

      expect(hash[1]).to eq(2)
    end

    it 'supports deletion' do

      hash[1] = 2

      expect(hash.delete(1)).to eq(2)
      expect(hash.size).to eq(0)
    end
  end

  context 'as a LRU Hash' do

    it 'drops entries when the maxsize is reached' do

      4.times { |i| hash[i] = i }

      expect(hash.size).to eq(3)
    end

    it 're-inserting under a key places the key at the end of the lru_keys' do

      3.times { |i| hash[i] = i }

      hash[0] = :new

      expect(hash.lru_keys).to eq([ 1, 2, 0 ])
    end

    it 'removes keys from the lru_keys upon entry deletion' do

      hash[1] = 1
      hash.delete(1)

      expect(hash.lru_keys).to eq([])
    end
  end

  describe '#initialize' do

    it 'fails when the maxsize is negative' do

      expect {
        Rufus::Lru::Hash.new(-1)
      }.to raise_error(ArgumentError, "maxsize must be >= 0")
    end
  end

  describe '#lru_keys' do

    it 'returns the keys with the least recently used first' do

      3.times { |i| hash[i] = i }

      expect(hash.lru_keys).to eq([ 0, 1, 2 ])
    end
  end

  describe '#ordered_keys' do

    it 'is an alias for #lru_keys' do

      3.times { |i| hash[i] = i }

      expect(hash.lru_keys).to eq([ 0, 1, 2 ])
    end
  end

  describe '#[]' do

    it 'returns nil if there is no value' do

      expect(hash[:x]).to eq(nil)
    end

    it 'returns false when the value is false' do

      hash[1] = false

      expect(hash[1]).to eq(false)
    end

    it 'does not modify the LRU list when looking up a non-present key' do

      hash[:x]

      expect(hash.lru_keys).to eq([])
    end

    it 'returns the current value' do

      hash[1] = 2

      expect(hash[1]).to eq(2)
    end
  end

  describe '#merge!' do

    it 'merges in place' do

      hash.merge!(1 => 1, 2 => 2)

      expect(hash.size).to eq(2)
      expect(hash.lru_keys.sort).to eq([ 1, 2 ])
    end
  end

  describe '#to_h' do

    it 'returns a new hash with the entries of the LRU hash' do

      4.times { |i| hash[i] = i }

      expect(hash.to_h.class).to eq(::Hash)
      expect(hash.to_h).to eq({ 1 => 1, 2 => 2, 3 => 3 })
    end
  end

  describe '#auto_squeeze?' do

    it 'returns true by default' do

      expect(hash.auto_squeeze?).to eq(true)
    end
  end

  describe '#auto_squeeze=' do

    it 'sets the auto_squeeze behaviour' do

      hash.auto_squeeze = false
      expect(hash.auto_squeeze?).to eq(false)

      hash.auto_squeeze = true
      expect(hash.auto_squeeze?).to eq(true)
    end

    it 'squeezes when passed true' do

      hash.auto_squeeze = false

      5.times { |i| hash[i] = i }
      expect(hash.size).to eq(5)

      hash.auto_squeeze = true
      expect(hash.size).to eq(2)
    end
  end

  describe '#squeeze!' do

    it 'squeezes' do

      hash.auto_squeeze = false

      5.times { |i| hash[i] = i }
      expect(hash.size).to eq(5)

      hash.squeeze!
      expect(hash.size).to eq(2)
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
      expect(destructor_was_called).to eq(2)

      hash.delete 4
      expect(destructor_was_called).to eq(3)

      hash.clear
      expect(destructor_was_called).to eq(5)
    end

    it 'accepts a lambda (to be called each time a value is removed)' do

      destroyed = []
      hash.on_removal = lambda { |val| destroyed << val }

      5.times { |i| hash[i] = "item#{i}" }
      expect(destroyed).to eq(%w[ item0 item1 ])

      hash.delete(4)
      expect(destroyed).to eq(%w[ item0 item1 item4 ])

      hash.clear
      expect(destroyed).to eq(%w[ item0 item1 item4 item2 item3 ])
    end
  end
end

