module PeriodicalsHelper
  # Returns true if the URL ends with /:year/:month/:day/:slug
  def periodicals_by_slug?
    params[:slug]
  end
  
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
end