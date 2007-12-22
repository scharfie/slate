require File.dirname(__FILE__) + '/../spec_helper'
require 'stylesheets_controller'

class StylesheetsController
  # for testing - if we don't specify this, we
  # get "No action defined" errors
  def custom; end
end

describe StylesheetsController do
  it "should cache stylesheet custom.css" do
    controller.should_receive(:cache_page).once
    get 'custom', :format => 'css'
    response.should be_success
    response.should_not be_redirect
    response.headers['type'].should == 'text/css; charset=utf-8'
    controller.class.page_cache_extension.should == '.css'
  end
end