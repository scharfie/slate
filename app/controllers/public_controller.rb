class PublicController < ApplicationController
  include Slate::Builder
  include Slate::ThemeSupport

  # we don't need to capture a user for the public side
  skip_before_filter :capture_user!
  skip_before_filter :authorize_space!
  before_filter :capture_page
  before_filter :prepend_theme_view_paths
  after_filter :perform_cache

protected
  # Set caching directory based on hostname
  # i.e. /public/cache/example.com
  def prepare_cache
    self.class.page_cache_directory = "#{Rails.public_path}/cache/#{request.host}"
  end
  
  # Caches the page based on requested permalink
  def perform_cache
    prepare_cache
    cache_page unless @page.nil?
  end

  # Sets active space based on domain
  def capture_space
    @space = Space.active = Space.find_by_domain(request.host)
    render :text => "No website configured at this address." and return false if @space.nil?
  end
  
  # Captures page based on URL (defaults to default page for space)
  def capture_page
    page_path = params[:page_path]
    page_path = '/' if page_path.blank?
    return @page = Page.find_by_permalink(page_path, @space)
  end
  
public
  def index
    render :text => "<h1>Page not found</h1>Unable to find page <em>#{params[:page_path].join('/')}</em><br /><pre>#{request.env.to_yaml}</pre>" and return if @page.nil?
    # params[:page_path] = @page.url.to_s if params[:page_path].blank?
    view_page
  end
end