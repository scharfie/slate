CssDryer::NcssHandler.class_eval do
  # Edge Rails patch
  def self.call(template)
    new(nil).render(template)
  end
  
  # We have to completely skip the ERB piece 
  # until CssDryer is updated for the new templating
  # mechanism in edge Rails
  def render(template)
    source = process(template.source)
    erb_trim_mode = ActionView::TemplateHandlers::ERB.erb_trim_mode

    # src = ::ERB.new("<% __in_erb_template=true %>#{template.source}", nil, erb_trim_mode, '@output_buffer').src
    src = ::ERB.new(source, nil, erb_trim_mode, '@output_buffer').src
  end
end