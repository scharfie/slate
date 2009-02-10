class ApplicationController < ActionController::Base
  include Slate::Navigation
  include Slate::Authentication

  # load helpers
  helper :all

  before_filter :capture_user!
  before_filter :configure_timezone
  
  # Manually load the enclosing resources
  # and then capture the space - this is done
  # so we can properly set the Space.active class
  # variable
  before_filter :load_enclosing_resources
  before_filter :capture_space
  before_filter :authorize_space!
  before_filter :capture_page!

protected
  # Stub method for controllers that do not use RC
  def load_enclosing_resources
  end

  # Assigns active space based on instance variable
  # (from resources_controller)
  def capture_space
    Space.active = @space and return true if slate?

    # Sets active space based on domain
    @space = Space.active = Space.find_by_domain(request.host)
    render :text => "No website configured at this address." and return false if @space.nil?
  end

  # Captures page based on URL (defaults to default page for space)
  def capture_page!
    # don't capture page for slate
    return true if slate?

    page_path = params[:page_path]
    page_path = '/' if page_path.blank?
    @page = Page.find_by_permalink(page_path, @space)
    render :text => "<h1>Page not found</h1>Unable to find page <em>#{params[:page_path].join('/')}</em><br /><pre>#{request.env.to_yaml}</pre>" and return if @page.nil?
  end
  
  def authorize_space!
    return true unless slate?
    return true if Space.active.nil?
    return true if Space.active.permit?(User.active)
    flash[:error] = 'You are not authorized to view this space.'
    redirect_to dashboard_url and return false
  end
  
  def configure_timezone
    Time.zone = current_user.time_zone if logged_in?
  end
end