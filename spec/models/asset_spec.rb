require File.dirname(__FILE__) + '/../spec_helper'
require_dependency 'asset'

class Asset
  def source_url=(value)
    value = "file://" + File.expand_path(File.join(File.dirname(__FILE__), '../assets/' + value))
    uri = URI.parse(value)
    data = File.read(uri.path)
    self.content_type = case File.extname(value)
      when '.png' : 'image/png'
      when '.zip' : 'application/zip'
    end
    self.temp_data = data
    self.filename  = uri.path.split('/')[-1]
  end
end

# change the asset root for testing
Slate::AttachmentFu.asset_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

describe Asset, "of dimensions 276x110" do
  fixtures :spaces, :assets
  
  setup do
    @space = Space.active = spaces(:test_space)
    @asset = @space.assets.create :source_url => '276x110.png'
  end

  it "should be created" do
    @asset.valid?.should == true
    @asset.parent_id.should be_nil
  end

  it "should have 3 thumbnails" do
    sizes = @asset.thumbnails.inject([]) do |sizes, e| 
      sizes << [e.width, e.height]
    end.sort
      
    sizes.should == [[75, 75], [100, 40], [240, 96]]
    @asset.thumbnails.count.should == 3
    
    @asset.has_thumbnail?('sq').should be_true
    @asset.has_thumbnail?('tn').should be_true
    @asset.has_thumbnail?('sm').should be_true
    @asset.has_thumbnail?('md').should be_false
    @asset.has_thumbnail?('lg').should be_false
  end
  
  it "should be related to space" do
    @space.assets.count.should == 1
    @space.assets_with_thumbnails.count.should == 4
  end
  
  it "should return filename for name" do
    @asset.name.should == '276x110.png'
  end
  
  it "should return custom name" do
    @asset.name = 'My custom name'
    @asset.name.should == 'My custom name'
  end
  
  it "should return the original for 'md' and 'lg'" do
    original_filename = @asset.public_filename
    @asset.public_filename('md').should == original_filename
    @asset.public_filename('lg').should == original_filename
  end  
end

describe Asset, "of dimensions 16x16" do
  fixtures :spaces, :assets
  setup do
    @space = Space.active = spaces(:test_space)
    @asset = @space.assets.create(:source_url => '16x16.png')
  end
  
  it "should have 0 thumbnails" do
    @asset.thumbnails.count.should == 0
    
    @asset.has_thumbnail?('sq').should be_false
    @asset.has_thumbnail?('tn').should be_false
    @asset.has_thumbnail?('sm').should be_false
    @asset.has_thumbnail?('md').should be_false
    @asset.has_thumbnail?('lg').should be_false
  end
  
  it "should return the original for all thumbnails" do
    original_filename = @asset.public_filename
    
    @asset.public_filename('sq').should == original_filename
    @asset.public_filename('tn').should == original_filename
    @asset.public_filename('sm').should == original_filename
    @asset.public_filename('md').should == original_filename
    @asset.public_filename('lg').should == original_filename
  end
end

describe Asset, "ZIP file hello_world.zip" do
  fixtures :spaces, :assets
  
  setup do
    @space = Space.active = spaces(:test_space)
    @asset = @space.assets.create :source_url => 'hello_world.zip'
  end
  
  it "should be a ZIP file" do
    @asset.should be_zip
  end
  
  it "should contain the files hello.txt and world.txt" do
    filenames = @asset.entries.map { |e| e.name }
    filenames.sort.should == ['hello.txt', 'world.txt']
  end
  
  it "should extract the files" do
    @space.should have(1).assets
    @asset.extract!
    @space.should have(3).assets(true)
  end
end