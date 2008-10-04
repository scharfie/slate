require File.dirname(__FILE__) + '/../spec_helper'

describe Permalink do
  fixtures :pages, :permalinks
  
  before(:each) do
    @page = Page.create!(:name => 'My example page', :space_id => 1)
  end
  
  it "should add a permalink to page" do
    @page.permalinks << Permalink.new(:name => @url)
    @page.should have(1).permalinks
  end
end