require File.dirname(__FILE__) + '/../spec_helper'

SPEC_ASSET_PATH = RAILS_ROOT / 'spec/assets'

describe UploadedFile, 'via path string' do
  before(:each) do
    @path = SPEC_ASSET_PATH / '276x110.png'
    @uploaded_file = UploadedFile.new(@path)
  end
  
  it "should have content type 'image/png'" do
    @uploaded_file.content_type.should == 'image/png'
  end
  
  it "should be 5,720 bytes" do
    @uploaded_file.size.should == 5_720
    @uploaded_file.length.should == 5_720
  end
  
  it "should have original filename '276x110.png'" do
    @uploaded_file.original_filename.should == '276x110.png'
  end
  
  it "should read content from file" do
    @uploaded_file.read.should == File.read(@path)
  end
end

describe UploadedFile, 'via Tempfile' do
  before(:each) do
    @tempfile = Tempfile.new('slate_spec_tempfile')
    @tempfile.write "My temporary file"
    @uploaded_file = UploadedFile.new(@tempfile, 'my_temporary_file.doc')
    @uploaded_file.rewind
  end

  it "should have filename matching path of tempfile" do
    @uploaded_file.filename.should == @tempfile.path
  end

  it "should have content type 'application/word'" do
    @uploaded_file.content_type.should == 'application/word'
  end
  
  it "should have original filename 'my_temporary_file.doc'" do
    @uploaded_file.original_filename.should == 'my_temporary_file.doc'
  end
  
  it "should read content from file" do
    @uploaded_file.read.should == "My temporary file"
  end
  
  it "should be 17 bytes" do
    @uploaded_file.size.should == 17
    @uploaded_file.length.should == 17
  end
end

describe UploadedFile, 'via StringIO' do
  before(:each) do
    @string = StringIO.new("A cool song")
    @uploaded_file = UploadedFile.new(@string, 'coolsong.mp3')
  end

  it "should have content type 'audio/mpeg'" do
    @uploaded_file.content_type.should == 'audio/mpeg'
  end
  
  it "should have original filename 'coolsong.mp3'" do
    @uploaded_file.original_filename.should == 'coolsong.mp3'
  end
  
  it "should read content from file" do
    @uploaded_file.read.should == "A cool song"
  end
  
  it "should be 11 bytes" do
    @uploaded_file.size.should == 11
    @uploaded_file.length.should == 11
  end
end