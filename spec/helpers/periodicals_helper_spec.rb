require File.dirname(__FILE__) + '/../spec_helper'

describe PeriodicalsHelper do
  def year()  { :year  => 2008 } end
  def month() { :month => 3 } end
  def day()   { :day   => 20 } end
  def slug()  { :slug  => 'my-first-article' } end
    
  def params=(v)
    stub!(:params).and_return(v)
  end
  
  it "should return true for periodicals_by_slug with /:year/:month/:day/:slug" do
    self.params = year + month + day + slug
    should be_periodicals_by_slug
  end

  it "should return true for periodicals_by_day with /:year/:month/:day" do
    self.params = year + month + day
    should be_periodicals_by_day
  end

  it "should return true for periodicals_by_month with /:year/:month" do
    self.params = year + month
    should be_periodicals_by_month
  end

  it "should return true for periodicals_by_year with /:year" do
    self.params = year
    should be_periodicals_by_year
  end
end
