module Slate
  module Version
    MAJOR, MINOR, MACRO = 0, 5, 0
    STRING = [MAJOR, MINOR, MACRO].join('.')
    
    # the next line is used by the 'touch_revision_storing_files'
    # Rake task to ensure this file always has the current revision
    
    # RANDOM_TOKEN: 0.129563514953531
    REVISION = '$Revision: 123 $'.match(/\d+/)[0] rescue nil
    
    # returns version and revision in the form 0.1.0 r40
    def self.to_s
      [STRING, REVISION].compact.join(' r')
    end
  end
end
