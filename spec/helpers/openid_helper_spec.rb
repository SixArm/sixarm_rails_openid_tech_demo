require 'spec_helper'

describe OpenidHelper do

  describe "#params_for_openid" do

    it "returns exactly the params with keys that start with 'openid.'" do
      params = {'openid.foo' => 'a', 'hello' => 'world', 'openid.goo' => 'b'}
      params_for_openid(params).should == {'openid.foo' =>'a', 'openid.goo' => 'b'}
    end

  end

end
