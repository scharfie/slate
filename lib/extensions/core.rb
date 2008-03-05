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

class Object
  # Credit: http://ozmm.org/posts/try.html
  #   @person ? @person.name : nil
  # vs
  #   @person.try(:name)
  def try(method)
    send method if respond_to? method
  end
  
  # Returns true if the object is not nil
  def not_nil?
    !nil?
  end  
end

class Hash
  # Simply invokes merge on the hash
  def +(other)
    merge(other)
  end  
end