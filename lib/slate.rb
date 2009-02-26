module Slate
  class << self
    attr_accessor :plugins
    def plugins
      @plugins ||= ActiveSupport::OrderedHash.new
    end
  end
end    