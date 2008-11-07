class PublicController < ApplicationController
  include Slate::Builder
  include Slate::ThemeSupport

  # we don't need to capture a user for the public side
  skip_before_filter :capture_user!
  skip_before_filter :authorize_space!
  before_filter :capture_page
  before_filter :prepend_theme_view_paths

protected
  # Sets active space based on domain
  def capture_space
    @space = Space.active = Space.find_by_domain(request.host)
  end
  
  # Captures page based on URL (defaults to default page for space)
  def capture_page
    page_path = params[:page_path]
    return @page = @space.default_page if page_path.blank?
    return @page = @space.pages.find_by_permalink(page_path)
  end
  
public
  def index
    raise "No page found" if @page.nil?
    params[:page_path] = @page.url.to_s if params[:page_path].blank?
    view_page
  end
end