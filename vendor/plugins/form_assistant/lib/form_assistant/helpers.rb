module RPH
  module FormAssistant
    # stores all form helpers
    FORM_HELPERS = [
      ActionView::Helpers::FormBuilder.field_helpers + 
      %w(date_select datetime_select time_select collection_select select country_select time_zone_select submit) - 
      %w(hidden_field label fields_for)
    ].flatten.freeze
    
    module Helpers
      # used to check against methods
      # called via the method_missing hook
      ELEMENTS = [:div, :span, :p].freeze
      
      def self.included(receiver)
        receiver.extend ClassMethods
      end
      
    private
      # wrapper(): used to easily add new methods to the FormAssistant
      #
      # Parameters:
      #   e       - the element that wraps the content
      #   attrs   - the attributes for that element (class, id, etc)
      #   content - the actual content to wrap
      #   binding - optional binding (required if a block is passed)
      #
      # Ex:
      #   def span(attrs = {}, &block)
      #     wrapper(:span, attrs, @template.capture(&block), block.binding)
      #   end
      def wrapper(e, attrs, content, binding = nil)
        # wraps an element having certain attributes around some
        # content for a template (in case you didn't realize that)
        Collector.wrap(e).having(attrs).around(content).for(@template, binding)
      end
      
    public      
      # submission(): used to generate the 'submit' button on a form
      # 
      # Parameters:
      #   value   - the button's value
      #   options - options that you'd normally pass to a submit() helper
      #             (Note: for attributes on the wrapper, use :attrs => { ... })
      #
      # Ex:
      #   <% form_for @project do |form| %>
      #     // form stuff
      #     <%= form.submission 'Save Project' %>
      #   <% end %>
      #
      #   Note: use :attrs => { ... } to target the surrounding <p> tag
      #   <%= form.submission 'Save Project', :attrs => { :class => 'submit' } %>
      #
      #   <p class="submit">
      #     <input type="submit" value="Save Project" ... />
      #   </p>
      # 
      #   (other options will apply to the submit input)
      def submission(value = 'Save Changes', options = {})
        wrapper(:p, { :class => 'submission' }.merge!(options.delete(:attrs) || {}), self.submit(value, options))
      end

      # cancel(): used to provide a "go back" method while on a form
      # 
      # Ex:
      #   <% form_for @project do |form| %>
      #     // form stuff
      #     <%= form.cancel %>
      #   <% end %>
      #
      # Other options inlude:
      #   <%= form.cancel 'Go Back' %>
      #   <%= form.cancel 'Go Back', :path => some_path %>
      def cancel(*args)
        options = args.extract_options!
        text    = options.delete(:text) || (args.first if args.first.is_a?(String)) || 'Cancel'
        path    = options.delete(:path) || @template.request.env['HTTP_REFERER']    || @template.send("#{@object_name.to_s.pluralize}_path")
        attrs   = { :class => 'cancel' }.merge!(options.delete(:attrs) || {})
        
        wrapper(:span, attrs, @template.link_to(text, path, options))
      end

      # This hook provides convenient way to wrap content with a div,
      # where the "missing method" becomes the CSS class for the div.
      # 
      # Ex:
      #   <% form_for @project do |form| %>
      #     <% form.admin_operations do %>
      #       // admin stuff
      #     <% end %>
      #   <% end %>
      #
      #   <form ... >
      #     <div class="admin-operations">
      #       // admin stuff
      #     </div>
      #   </form>
      #
      # Any underscored methods will become a dasherized CSS class by
      # default; however, if you'd rather the underscored method translate
      # to multiple CSS classes, pass a :glue => ' ' option
      #
      #   <% form.admin_operations :glue => ' ' do %>
      #     // admin operations stuff
      #   <% end %>
      #
      #   <div class="admin operations">
      #     // admin operations stuff
      #   </div>
      #
      # Note: special attention has been given to certain HTML elements
      # 
      # <%= form.div :class => 'separator' do %>
      #   // div content
      # <% end %>
      #
      # <div class="separator">
      #   // div content
      # </div>
      #
      # Other options include:
      #   <%= form.p :class => 'whatever', :id => 'dom_id' do %>
      #   <%= form.span :class => 'note' do %>
      #
      def method_missing(method, *args, &block)
        super(method, *args) unless block_given?
        options, attrs, element = (args.detect { |arg| arg.is_a?(Hash) } || {}), {}, nil

        # handle methods separately if they match the pre-defined elements
        if ELEMENTS.include?(method.to_sym)
          attrs, element = options, method
        else 
          attrs, element = { :class => method.to_s.downcase.gsub('_', options[:glue] || ' ') }, :div 
        end
        
        wrapper(element, attrs, @template.capture(&block), block.binding)
      end
      
      module ClassMethods
        protected
          # convenience method for accessing available helpers
          def form_helpers
            ::RPH::FormAssistant::FORM_HELPERS
          end
      end
    end
  end
end