
require 'spec_helper'


describe Rufus::Lru::Hash do

  context 'when maxsize is zero' do

    let(:hash) { Rufus::Lru::Hash.new(0) }

    it 'does not cache at all'
#
#      hash[1] = 2
#
#      expect(hash.size).to eq(0)
#      expect(hash[1]).to eq(nil)
#    end
  end
end

