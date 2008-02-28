require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do
  attr_accessor :erb_output

  before(:each) do
    self.erb_output = ''
  end
  
  it "should store content for book_collection using string" do
    lambda { content_for_variable('book_collection', 'Programming Ruby') }.
      should change { @content_for_book_collection }.from(nil).to('Programming Ruby')
  end
  
  it "should store content for book_collection using block" do
    lambda { content_for_variable('book_collection') { concat('Programming Ruby', binding) } }.
      should change { @content_for_book_collection }.from(nil).to('Programming Ruby')
  end
  
  it "should store content for book_collection using string and block" do
    lambda { content_for_variable('book_collection', 'Programming ') { concat('Ruby', binding) } }.
      should change { @content_for_book_collection }.from(nil).to('Programming Ruby')
  end
  
  it "should store content for heading using string and block" do
    lambda { heading('My ') { concat('Heading', binding) } }.
      should change { @content_for_heading }.from(nil).to('My Heading')
  end

  it "should store content for head using string and block" do
    lambda { head('Hello ') { concat('Chris', binding) } }.
      should change { @content_for_head }.from(nil).to('Hello Chris')
  end
  
  it "should render space chooser" do
    @spaces = []
    Space.should_receive(:find).with(:all, :order => 'name').and_return(@spaces)
    should_receive(:render).with(:partial => 'shared/space_chooser', :locals => { :spaces => @spaces})
    space_chooser
  end
  
  it "should create a cancel link" do
    @link = link_to_cancel(:controller => 'dashboard')
    @link.should == '<a href="/dashboard" class="cancel">Cancel</a>'
  end
  
  it "should create a cancel link for current resources url" do
    should_receive(:resources_url).and_return('/spaces/1/pages')
    @link = link_to_cancel
    @link.should == '<a href="/spaces/1/pages" class="cancel">Cancel</a>'
  end
  
  it "should create an image tag for glyph 'exclamation'" do
    @image = glyph('exclamation')
    @image.should include('/images/glyphs/exclamation.png')
    @image.should include('class="glyph"')
  end

  it "should create an image tag for glyph 'exclamation' with options" do
    @image = glyph('exclamation', :class => 'my_class', :alt => 'Custom alt')
    @image.should include('/images/glyphs/exclamation.png')
    @image.should include('class="my_class glyph"')
    @image.should include('alt="Custom alt"')
  end
  
  it "should escape the given javascript" do
    @javascript = <<-JS
    alert("Hello, 'Chris'!");}
    JS
    js(@javascript).should == escape_javascript(@javascript)
  end
  
  it "should create span tag" do
    span('chrisscharf').should == '<span>chrisscharf</span>'
    span('chrisscharf', :class => 'name').should == 
      '<span class="name">chrisscharf</span>'
  end
  
  it "should return 'slate' link to dashboard" do
    dashboard_heading.should == 
      '<span class="slate"><a href="/dashboard">slate</a></span>'
  end
  
  it "should return nothing for space heading with no active space" do
    Space.should_receive(:active).and_return(nil)
    space_heading.should == nil
  end
  
  it "should return link to active space" do
    Space.stub!(:active).and_return(@space = mock(Space))
    @space.stub!(:to_param).and_return(155)
    @space.stub!(:name).and_return('Demo site')
    space_heading.should == 
      '<span class="space"><a href="/spaces/155/dashboard">Demo site</a></span>'
  end
  
  it "should return 'Administrator' span when super user" do
    should_receive(:super_user?).and_return(true)
    admin_heading.should == 
      '<span class="space">Administrator</span>'
  end

  it "should return nothing when not super user" do
    should_receive(:super_user?).and_return(false)
    admin_heading.should == nil
  end

end