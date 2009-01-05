module ActionView
  class PathSet
    class Path
    public  
      def reload!
        @paths = {}

        templates_in_path do |template|
          # Hacked - never freeze theme templates
          template.freeze if self.class.eager_load_templates? unless template.load_path.to_s.include?('public/themes')

          @paths[template.path] = template
          @paths[template.path_without_extension] ||= template
        end

        @paths.freeze
        @loaded = true
      end

    private
      def templates_in_path
        files = if @path.include?('public/themes')
          Dir.glob("#{@path}/**/*.html.erb")
        else
          (Dir.glob("#{@path}/**/*/**") | Dir.glob("#{@path}/**"))
        end
            
        files.each do |file|
          unless File.directory?(file)
            yield Template.new(file.split("#{self}/").last, self)
          end
        end
      end      
    end
  end
end