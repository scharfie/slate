desc "copies basic form templates to app/views/forms"
namespace :form_assistant do
  task :install do
    PLUGIN_ROOT = File.join(File.dirname(__FILE__), '..')
    DESTINATION = File.join(Rails.root, 'app/views', 'forms')

    FileUtils.mkpath(DESTINATION) unless File.directory?(DESTINATION)
    forms = Dir[File.join(PLUGIN_ROOT, 'forms/*')].select { |f| File.file?(f) }
    longest_filename = forms.inject([]) { |sizes, f| sizes << f.gsub(PLUGIN_ROOT, '').length }.max

    forms.each do |partial|
      file_to_copy = File.join(DESTINATION, '/', File.basename(partial))
      puts " - form_assistant%-#{longest_filename}s copied to %s" %
        [partial.gsub(PLUGIN_ROOT, ''), DESTINATION.gsub(Rails.root, '')]
      FileUtils.cp [partial], DESTINATION
    end
  end
end