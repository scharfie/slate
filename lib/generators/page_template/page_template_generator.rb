class PageTemplateGenerator < Rails::Generator::Base
  def initialize(*args)
    super(*args)
    @name = args[0][0]
    @theme = args[0][1]
    unless @name and @theme
      puts "Usage: ./script/generate page_template template_name theme"
      exit
    end
  end
  
  def manifest
    record do |m|
      m.directory File.join('public', 'themes', @theme)
      m.file 'page_template.rhtml', File.join('public', 'themes', @theme, "#{@name}.rhtml")
    end
  end
end
