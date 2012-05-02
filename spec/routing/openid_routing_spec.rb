require 'spec_helper'

describe "OpenID Routing" do

  describe ":openid" do
   
    it "routes GET :openid_root => openid#index" do
      { :get => openid_root_path }.should route_to(:controller => "openid", :action => "index")
    end
      
    it "!routes" do
      { :post => openid_root_path }.should_not be_routable
    end
      
  end

  describe ":openid_begin" do
      
    it "routes POST :openid_begin => openid#begin" do
      { :post => openid_begin_path }.should route_to(:controller => "openid", :action => "begin")
    end
    
    it "!routes" do
      { :get => openid_begin_path }.should_not be_routable
    end
    
  end

  describe ":openid_complete" do
      
    it "routes GET :open_complete => openid#complete" do
      { :get => openid_complete_path }.should route_to(:controller => "openid", :action => "complete")
    end
      
    it "!routes" do
      { :post => openid_complete_path }.should_not be_routable
    end
      
  end

end
