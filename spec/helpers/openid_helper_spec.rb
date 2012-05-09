require 'spec_helper'

describe OpenidHelper do

  describe "#params_for_openid" do

    it "returns exactly the params with keys that start with 'openid.'" do
      params = {'openid.foo' => 'a', 'hello' => 'world', 'openid.goo' => 'b'}
      params_for_openid(params).should == {'openid.foo' =>'a', 'openid.goo' => 'b'}
    end

    it "preserves the params class as HashWithIndifferentAccess" do
      params_for_openid(HashWithIndifferentAccess.new).should be_a_kind_of(HashWithIndifferentAccess)
    end

  end

end
