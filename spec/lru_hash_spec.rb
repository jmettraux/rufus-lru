
require 'spec_helper'


describe LruHash do

  it 'is available from the root namespace' do

    h = LruHash.new(1)

    2.times { |i| h[i] = i }

    h.size.should == 1
  end
end

