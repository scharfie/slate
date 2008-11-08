require File.dirname(__FILE__) + '/../spec_helper'

describe PeriodicalsHelper do
  def year()  { :year  => 2008 } end
  def month() { :month => 3 } end
  def day()   { :day   => 20 } end
  def slug()  { :slug  => 'my-first-article' } end
    
  before(:each) do
    assigns[:controller] = self
  end  
    
  def helper.params=(v)
    stub!(:params).and_return(v)
  end

  def params=(v)
    stub!(:params).and_return(v)
  end
  
  it "should return true for periodicals_by_slug with /:year/:month/:day/:slug" do
    helper.params = year + month + day + slug
    helper.should be_periodicals_by_slug
  end

  it "should return true for periodicals_by_day with /:year/:month/:day" do
    helper.params = year + month + day
    helper.should be_periodicals_by_day
  end

  it "should return true for periodicals_by_month with /:year/:month" do
    helper.params = year + month
    helper.should be_periodicals_by_month
  end

  it "should return true for periodicals_by_year with /:year" do
    helper.params = year
    helper.should be_periodicals_by_year
  end
  
  it "should return periodical URL and path for article" do
    helper.params = { :page_path => ['some', 'page', 'path'], 
      :controller => 'public', :action => 'index' }
    @periodical = mock('SomePeriodical')
    @periodical.stub!(:published_at).and_return(Time.local(2008, 3, 20, 12, 0, 0))
    @periodical.stub!(:permalink).and_return('an-example-article-permalink')
    
    url = '/some/page/path/2008/03/20/an-example-article-permalink'
    
    # We have to manually pass the controller and action for rspec
    options = { :controller => 'public', :action => 'index' }
    helper.periodical_path(@periodical, options).should == url
    helper.periodical_url(@periodical, options).should == 'http://test.host' + url
  end
end
