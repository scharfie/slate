CssDryer::NcssHandler.class_eval do
  # Add compilable? method for edge Rails
  def compilable?
    false
  end
end