require File.dirname(__FILE__) + '/../spec_helper'

describe Page do
  fixtures :pages
  it "should be created" do
    @page = Page.create(:name => 'My Test Page', :space_id => 1)
    Page.count.should == 2
    
    @page.should be_valid
    @page.parent_id.should == 1
    @page.reload
    @page.parent.should_not be_nil
  end
end

describe Page do
  fixtures :pages, :spaces, :permalinks
  
  before(:each) do
    @page = Page.create!(:name => 'Address', :space_id => 1)
    @page.permalinks << Permalink.new(:name => '/wv/morgantown', :is_default => true)
    @page.permalinks << Permalink.new(:name => '/wv/granville')
  end

  it "should find page by permalink '/wv/morgantown'" do
    Page.find_by_permalink('/wv/morgantown').should == @page
  end
  
  it "should find page by permalink /wv/granville" do
    Page.find_by_permalink('/wv/morgantown').should == @page
  end
  
  it "should not find page with invalid permalink" do
    Page.find_by_permalink('/wv/sabraton').should be_nil
  end
  
  it "should return default permalink '/wv/morgantown" do
    @page.permalink.name.should == '/wv/morgantown'
  end
end

describe Page do
  fixtures :pages, :spaces, :areas, :users

  before(:each) do
    User.active = users(:cbscharf)
    Space.active = spaces(:test_space)
    
    @space = spaces(:test_space)
    @home = @space.pages.create(:name => 'Home')
    @about = @space.pages.create(:name => 'About')
    
    # create default content for @header
    @header = @home.content_for(:header)
    @header.update_attributes(:body => 'HeaderContent', :is_default => true)
  end
  
  it "should return default content from Home for About/header" do
    @about.content_for(:header).should == @header
  end
  
  it "should return custom content for About/header" do
    @area = @about.areas.create!(:key => 'header', :body => 'CustomHeaderContent')
    @about.content_for(:header).should == @area
  end
  
  it "should return default content for About/header in production" do
    @published_header = @header.publish!
    @about.content_for(:header, :production).should == @published_header
  end
  
  it "should return custom content for About/header in production" do
    @area = @about.areas.create!(:key => 'header', :body => 'CustomHeaderContent')
    @published_header = @header.publish!
    @published_area = @area.publish!
    @about.content_for(:header, :production).should == @published_area
  end
end

describe "Pages collection in space" do
  fixtures :pages, :spaces
  
  before(:each) do
    @space = spaces(:test_space)
  end
  
  it "should auto-create root" do
    @space.pages.size.should == 0
    @space.pages.create(:name => 'My test page')
    @space.pages(true).size.should == 2
  end
end