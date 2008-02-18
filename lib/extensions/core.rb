class String
  # Converts the string to all lowercase,
  # replaces all non-alphanumeric characters with specified glue
  # (any leading and training glue will be removed)
  def permalink(glue='-')
    downcase.gsub(/[^a-z0-9]/, glue).split(glue).reject(&:empty?).join(glue)   
  end
  
  # Joins strings together using File.join
  def /(other)
    File.join(self, other)
  end
end