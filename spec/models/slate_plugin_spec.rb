require File.dirname(__FILE__) + '/../spec_helper'

module SlatePluginSpecHelper
  def load_plugin(class_name)
    name = class_name.underscore
    @path = App.root / 'spec/plugins' / name
    load @path / name + '.rb'
    @plugin = class_name.constantize.new(@path)
  end

  def create_mock_initializer
    @config = mock(Object)
    @config.stub!(:controller_paths).and_return([])
    @initializer = mock(Rails::Initializer)
    @initializer.stub!(:configuration).and_return(@config)
    return @initializer
  end
end

describe Slate::Plugin, ' (DummyPlugin)' do
  include SlatePluginSpecHelper
  
  before(:each) do
    Slate.plugins.clear
    @plugin = load_plugin 'DummyPlugin'
  end
  
  it "should return path to /app" do
    @plugin.send(:app_path).should include('dummy_plugin/app')
  end
  
  it "should have directory (root)/spec/plugins/dummy_plugin" do
    @plugin.directory.should == App.root / 'spec/plugins/dummy_plugin'
  end
  
  it "should be a valid plugin" do
    @plugin.should be_valid
  end  
    
  it "should have plugin name 'DummyPlugin'" do
    @plugin.plugin_name.should == 'DummyPlugin'
  end  
    
  it "should have name 'Dummy'" do
    @plugin.name.should == 'Dummy'
  end
  
  it "should have description 'A dummy plugin for testing'" do
    @plugin.description.should == 'A dummy plugin for testing'
  end
  
  it "should have pending migrations" do
    @plugin.should be_pending_migrations
  end
  
  it "should have current migration version 0" do
    @plugin.current_version.should == 0
  end
  
  it "should have migratable version 1" do
    @plugin.migratable_version.should == 1
  end
  
  it "should fail to load due to pending migrations" do
    @initializer = create_mock_initializer
    
    @plugin.should_receive(:pending_migrations_error).once
    @plugin.load(@initializer)
  end
  
  it "should load (when no migrations are pending)" do
    @plugin.should_receive(:pending_migrations?).and_return(false)
    @initializer = create_mock_initializer
    
    @plugin.should_not be_loaded
    @plugin.load(@initializer)
    @plugin.should be_loaded
    
    Slate.should have(1).plugins
  end
  
  it "should set configuration paths when loaded" do
    path = @plugin.directory / 'app'
    
    ActiveSupport::Dependencies.stub!(:load_paths).and_return([])
    ActionController::Base.should_receive(:append_view_path).
      with(path / 'views')
    
    @initializer = create_mock_initializer
    @plugin.init_dependencies(@initializer)
    
    ActiveSupport::Dependencies.load_paths.should == [
      path / 'controllers',
      path / 'models',
      path / 'helpers'
    ]
    
    @config.controller_paths.should == [path / 'controllers']
  end
end