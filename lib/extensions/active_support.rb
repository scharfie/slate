module ActiveSupport
  if RUBY_VERSION < '1.9'
    class OrderedHash < Array #:nodoc:
      def merge!(other)
        other.each do |pair|
          self.send(:[]=, *pair)
        end
      end
      
      alias_method :update, :merge!
    end
  end
end