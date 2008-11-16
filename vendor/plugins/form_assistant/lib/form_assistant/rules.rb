module RPH
  module FormAssistant
    private
      # used to assist generic logic throughout FormAssistant
      class Rules
        # used mainly for #concat() so that this plugin will
        # work with versions of Rails other than edge
        def self.binding_required?
          !!( Rails.version < '2.2.0' )
        end
      end
  end
end