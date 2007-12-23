module SalutationsHelper
  def express_salutation(msg)
    content_tag(:h3, msg, :class => 'example_slate_plugin')
  end
end