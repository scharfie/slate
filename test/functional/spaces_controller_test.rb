require File.dirname(__FILE__) + '/../test_helper'
require 'spaces_controller'

# Re-raise errors caught by the controller.
class SpacesController; def rescue_action(e) raise e end; end

class SpacesControllerTest < Test::Unit::TestCase
  def setup
    @controller = SpacesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:spaces)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_space
    old_count = Space.count
    post :create, :space => { }
    assert_equal old_count+1, Space.count
    
    assert_redirected_to space_path(assigns(:space))
  end

  def test_should_show_space
    @space = Space.create()
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    @space = Space.create()
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_space
    @space = Space.create()
    put :update, :id => 1, :space => { }
    assert_redirected_to space_path(assigns(:space))
  end
  
  def test_should_destroy_space
    @space = Space.create()
    old_count = Space.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Space.count
    
    assert_redirected_to spaces_path
  end
end
