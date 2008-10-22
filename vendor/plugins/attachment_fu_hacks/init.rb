# Hacked to fix attachment_fu with edge Rails
klass = Technoweenie::AttachmentFu::InstanceMethods
klass.module_eval do
  def self.included( base )
    base.define_callbacks *[:after_resize, :after_attachment_saved, :before_thumbnail_saved]
  end  

  def callback_with_args(method, arg = self)
    notify(method)
    
    options = { :object => arg }
    options[:object] = [self, arg] if method == :before_thumbnail_saved
    
    result = run_callbacks(method, options) { |result, object| result == false }

    if result != false && respond_to_without_attributes?(method)
      result = send(method)
    end

    return result
  end      

  def run_callbacks(kind, options = {}, &block)
    options.reverse_merge!( :object => self, :parent => self )
    ::ActiveSupport::Callbacks::CallbackChain.new(self.class.send("#{kind}_callback_chain")).run(options[:object], options, &block)
  end      
end