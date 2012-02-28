
require 'spec_helper'


describe Rufus::Lru::SynchronizedHash do

  # well, you've probably seen better specs...

  let(:hash) { Rufus::Lru::SynchronizedHash.new(3) }

  it 'sports a mutex' do

    hash.instance_variable_get(:@mutex).class.should == Mutex
  end

  it 'works' do

    4.times { |i| hash[i] = i }

    hash.size.should == 3
  end
end

