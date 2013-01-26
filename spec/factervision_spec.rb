require 'spec_helper'

describe FacterVision::Application do

  describe "GET '/'" do
    it "should return the index page." do
      get '/'
      last_response.should be_ok
    end
  end

  describe "GET '/api'" do
    it "should get the API page" do
      get '/api'
      last_response.should be_ok
    end
  end

  describe "GET '/about'" do
    it "should get the about page" do
      get '/about'
      last_response.should be_ok
    end
  end

end
