require File.dirname(__FILE__) + '/../spec_helper'

describe Area do
  fixtures :areas, :spaces, :users, :pages
  
  before(:each) do
    User.active = users(:cbscharf)
    Space.active = spaces(:test_space)
    @page = Space.active.pages.create!(:name => 'Home')
    @area = @page.areas.build(:key => 'main')
  end

  it "should be valid" do
    @area.should be_valid
  end
  
  it "should compile the 'body' column" do
    @area.body = "This _is_ a test."
    @area.save!
    @area.body_html.should == "<p>This <em>is</em> a test.</p>"
  end
  
  it "should have correct dom_id" do
    @area.dom_id.should == 'area-%s-main' % @page.id
  end
  
  it "should return key 'main' for URL parameter" do
    @area.to_param.should == 'main'
  end
  
  it "should have 0 versions" do
    @area.should have(0).versions
  end
  
  it "should publish version 1" do
    @area.body = "This _is_ a test."
    @area.save
    
    @published = @area.publish!
    @published.should be_a_kind_of(Area)
    @published.should_not be_new_record
    @published.version.should == 1
    @published.page.should == @page
    @published.area_id.should == @area.id
    
    @published.published_at.should_not be_nil
    
    @area.should have(1).versions
    @area.published_version.should == @published
  end
  
  it "should publish remove oldest version" do
    4.downto(1) do |version|
      @area.update_attribute(:body, "Version #{version}")
      @area.publish!
    end
    
    @version = @area.versions.find_by_version(4)
    @version.body.should == "Version 4"
    @area.publish!
    
    # find the new version with version==4
    # (note that the body is Version 3 from the initial publish)
    @version = @area.versions.find_by_version(4)
    @version.body.should == "Version 3"
  end
  
  it "should not be default" do
    @area.should_not be_default
  end
  
  it "should be default after marking for current page" do
    @area.mark!
    @area.should be_default
    @area.should be_default(@page)
  end
  
  it "should be default after marking but not for different page" do
    @different_page = Page.new
    @area.mark!
    @area.should be_default
    @area.should be_default(@page)
    @area.should_not be_default(@different_page)
    @area.should be_using_default(@different_page)
  end
  
  it "should not be default after marking and then unmarking" do
    @area.mark!
    @area.should be_default
    @area.unmark!
    @area.should_not be_default
  end
  
  it "should toggle default" do
    @area.should_not be_default
    @area.toggle!
    @area.should be_default
    @area.toggle!
    @area.should_not be_default
  end
  
  it "should find default content for space 1 and key 'header'" do
    @area.key = 'header'
    @area.mark!
    @area.page.space_id.should == 1
    
    Area.default_content_for(1, 'header').should == @area
  end
end

describe Area, 'on two different pages' do
  fixtures :areas, :spaces, :users, :pages
  
  before(:each) do
    User.active = users(:cbscharf)
    Space.active = spaces(:test_space)
    @page_one = Space.active.pages.create!(:name => 'First')
    @page_two = Space.active.pages.create!(:name => 'Second')
    @area_one = @page_one.areas.build(:key => 'main')
    @area_one.mark!
    @area_two = @page_two.areas.build(:key => 'main')
  end

  it "should show default area on second page for 'main'" do
    @page_one.content_for(:main).should == @area_one
    @page_two.content_for(:main).should == @area_one
  end

  it "should show custom area on second page for 'main'" do
    @area_two.save
    @page_one.content_for(:main).should == @area_one
    @page_two.content_for(:main).should == @area_two
  end
  
  it "should show custom area on second page for 'main'" do
    @area_two.mark!
    @area_one.reload
    @area_one.should_not be_default
    
    @page_one.content_for(:main).should == @area_one
    @page_two.content_for(:main).should == @area_two
  end

end