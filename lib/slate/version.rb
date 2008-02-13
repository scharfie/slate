module Slate
  module Version
    MAJOR, MINOR, MACRO = 0, 5, 0
    STRING = [MAJOR, MINOR, MACRO].join('.')
        
    def self.to_s
      STRING
    end
  end
end
