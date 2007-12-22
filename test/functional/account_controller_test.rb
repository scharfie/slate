require File.dirname(__FILE__) + '/../test_helper'
require 'account_controller'

# Re-raise errors caught by the controller.
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < Test::Unit::TestCase
  def setup
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_show_login_on_get
    get :login
    assert_response :success
    assert assigns(:account)
  end
  
  def test_should_process_login_on_post
    post :login, :account =>  { :username => 'cbscharf', :password => 'test' }
    assert_response :success
  end
end
