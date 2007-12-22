module ActiveRecord
  module Associations
    class HasManyThroughAssociation
      alias_method :new, :build
    end
    class HasManyAssociation
      alias_method :new, :build
    end
    class HasAndBelongsToManyAssociation
      alias_method :new, :build
    end
  end
end