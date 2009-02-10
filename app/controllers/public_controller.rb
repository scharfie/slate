class PublicController < ApplicationController
  include Slate::Builder
  include Slate::ThemeSupport

  before_filter :prepend_theme_view_paths
  after_filter  :perform_cache

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

public
  def index
    view_page
  end
end