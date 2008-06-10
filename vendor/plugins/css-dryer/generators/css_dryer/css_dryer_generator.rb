class CssDryerGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.file 'stylesheets_controller.rb',
             'app/controllers/stylesheets_controller.rb',
             :chmod => 0644,
             :collision => :ask
      m.file 'stylesheets_helper.rb',
             'app/helpers/stylesheets_helper.rb',
             :chmod => 0644,
             :collision => :skip
      m.directory 'app/views/stylesheets'
      m.file 'test.ncss',
             'app/views/stylesheets/test.ncss',
             :chmod => 0644,
             :collision => :skip
    end
  end
end
