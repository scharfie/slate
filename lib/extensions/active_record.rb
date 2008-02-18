module ActiveRecord # :nodoc:
  module Associations # :nodoc:
    class HasManyThroughAssociation # :nodoc:
      alias_method :new, :build
    end
    class HasManyAssociation # :nodoc:
      alias_method :new, :build
    end
    class HasAndBelongsToManyAssociation # :nodoc:
      alias_method :new, :build
    end
  end
end