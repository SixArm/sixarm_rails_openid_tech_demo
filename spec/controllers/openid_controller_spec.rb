require 'spec_helper'

describe OpenidController do

  # Doubles
  let(:consumer) { double("OpenID::Consumer") }
  let(:checkid_request) { double ("OpenID::Consumer::CheckIDRequest") }
  let(:response) { double ("OpenID::Consumer::Response") }
  let(:openid_url) { "http://example.com" }

  # URLs that must match the controller
  let(:default_url) { "/openid" } 
  let(:redirect_url) { "#{root_url}/openid/complete" } 

  describe "GET index" do

    it "shows the index page" do
      get :index
      response.should render_template('index')
    end

  end

  describe "POST begin" do

    before do
      OpenID::Consumer.stub(:new) { consumer }
      checkid_request.stub(:redirect_url) { redirect_url }
    end

    context "with a valid openid url" do

      before do
        # A valid openid url causes consumer.begin to return a checkid_request
        consumer.stub(:begin) { checkid_request }
      end

      it "begins" do
        OpenID::Consumer.should_receive(:new).with(kind_of(Hash), nil)
        consumer.should_receive(:begin).with(openid_url)
        checkid_request.should_receive(:redirect_url).with(kind_of(String), kind_of(String))
        post :begin, :openid_url => openid_url
        flash[:notice].should == nil
        flash[:error].should == nil
        response.should redirect_to redirect_url
      end

    end

    context "with an invalid openid url" do

      before do
        # An invalid openid url causes consumer.begin to raise an error
        consumer.stub(:begin) { raise OpenID::DiscoveryFailure.new("",nil) }
      end

      it "begins" do
        OpenID::Consumer.should_receive(:new).with(kind_of(Hash), nil)
        consumer.should_receive(:begin).with(openid_url)
        post :begin, "openid_url" => openid_url
        flash[:notice].should == nil
        flash[:error].should ==  "Couldn't find an OpenID for that URL"
        response.should redirect_to default_url
      end

    end

    context "with a blank opendid url" do

      it "redirects to the index page to try again" do
        post :begin, "openid_url" => ""
        flash[:notice].should == nil
        flash[:error].should =~ /^To use this/
        response.should redirect_to default_url
      end

    end

  end

  describe "GET complete" do

    before do
      OpenID::Consumer.stub(:new) { consumer }
      consumer.stub(:complete) { response }
      response.stub(:identity_url) { "http://foo" }
      response.stub(:endpoint) { "endpoint123" }
      response.stub(:message) { "message123" }
      response.stub(:contact) { "contact123" }
    end

    context "with success response" do

      before do
        response.stub(:status) { OpenID::Consumer::SUCCESS }
        consumer.should_receive(:complete).with(kind_of(Hash))
        response.should_receive(:identity_url)
      end

      it "says success then redirects to root path" do
        get :complete, {}
        flash[:notice].should =~ /^Success/
        flash[:error].should == nil
        response.should redirect_to root_path
      end

    end

    context "with failure response" do

      before do
        response.stub(:status) { OpenID::Consumer::FAILURE }
        consumer.should_receive(:complete).with(kind_of(Hash))
        response.should_not_receive(:identity_url)
      end

      it "says failure then redirects to retry" do
        get :complete, {}
        flash[:notice].should == nil
        flash[:error].should =~ /^Failure/
        response.should redirect_to default_url
      end

    end

    context "with cancel response" do
      
      before do
        response.stub(:status) { OpenID::Consumer::CANCEL }
        consumer.should_receive(:complete).with(kind_of(Hash))
        response.should_not_receive(:identity_url)
      end

      it "says cancel then redirects to retry" do
        get :complete, {}
        flash[:notice].should =~ /^Cancel/
        flash[:error].should == nil
        response.should redirect_to default_url
      end

    end

    context "with setup needed response" do

      before do
        response.stub(:status) { OpenID::Consumer::SETUP_NEEDED }
        consumer.should_receive(:complete).with(kind_of(Hash))
        response.should_not_receive(:identity_url)
      end
      
      it "says setup needed then redirects to retry" do
        get :complete, {}
        flash[:notice].should == nil
        flash[:error].should =~ /^Setup/
        response.should redirect_to default_url
      end

    end

  end

end
