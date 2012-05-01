require 'spec_helper'

describe "openid" do

  it "displays the openid form" do

    get "/openid"
    assert_select "form" do
      assert_select "input[name=?]", "openid_url"
      assert_select "input[type=?]", "submit"
    end

    post "/openid/begin", :url => ""
    response.should redirect_to "/openid"

  end

end
