module PeriodicalsHelper
  # Returns true if the URL ends with /:year/:month/:day/:slug
  def periodicals_by_slug?
    params[:slug]
  end
  
  alias_method :periodical_by_slug?, :periodicals_by_slug?
  
  # Returns true if the URL ends with /:year/:month/:day
  def periodicals_by_day?
    params[:day] && !params[:slug]
  end
  
  # Returns true if the URL ends with /:year/:month
  def periodicals_by_month?
    params[:month] && !params[:day]
  end

  # Returns true if the URL ends with /:year
  def periodicals_by_year?
    params[:year] && !params[:month]
  end

  # Returns URL path to periodical
  # Note: The periodical must respond to 
  # +published_at+ and +permalink+
  def periodical_path(e, options={})
    url_for hash_for_periodical_path(e, options)
  end
  
  # Returns hash of options for periodical
  def hash_for_periodical_path(e, options={})
    year, month, day = (e.published_at || e.updated_at).strftime('%Y/%m/%d').split('/')
    slug = e.permalink
    options.reverse_merge! :page_path => params[:page_path] unless params[:page_path].blank?
    options.reverse_merge! :year => year, :month => month, :day => day, :slug => slug
  end
  
  def cache_paths_for_periodical(e)
    return [] if e.new_record?
    
    options = {}
    [
      periodical_path(e, options),
      periodical_path(e, options.merge(:slug  => nil, :day => nil)),
      periodical_path(e, options.merge(:month => nil)),
      periodical_path(e, options.merge(:year  => nil)),
    ]  
  end

  # Returns full URL (including host) to periodical
  def periodical_url(e, options={})
    periodical_path e, options.merge(:only_path => false)
  end
end