module ActiveSupport
  module Inflector
    # Patched to work with slate-plugin-* plugins
    # which throw "Plugins::Slate-plugin-*::App::Controllers" is not a valid constant name!
    # when the plugin directory has dashes in the name
    # 
    # Only one thing was changed - the gsub was amended with '|-'
    def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
      if first_letter_in_uppercase
        lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_|-)(.)/) { $1.upcase }
      else
        lower_case_and_underscored_word.first + camelize(lower_case_and_underscored_word)[1..-1]
      end
    end   
  end
end    