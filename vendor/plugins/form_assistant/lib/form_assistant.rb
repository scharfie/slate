%w(error rules builder collector helpers).each do |f|
  require File.join(File.dirname(__FILE__), 'form_assistant', f)
end

# Developed by Ryan Heath (http://rpheath.com)
module RPH
  # The idea is to make forms extremely less painful and a lot more DRY
  module FormAssistant
    # FormAssistant::FormBuilder
    #   * provides several convenient helpers (see helpers.rb) and
    #     an infrastructure to easily add your own
    #   * method_missing hook to wrap content "on the fly"
    #   * optional: automatically attach labels to field helpers
    #   * optional: format fields using partials (extremely extensible)
    # 
    # Usage:
    #
    #   <% form_for @project, :builder => RPH::FormAssistant::FormBuilder do |form| %>
    #     // fancy form stuff
    #   <% end %>
    #
    #   - or -
    # 
    #   <% form_assistant_for @project do |form| %>
    #     // fancy form stuff
    #   <% end %>
    #
    #   - or -
    #
    #   # in config/intializers/form_assistant.rb
    #   ActionView::Base.default_form_builder = RPH::FormAssistant::FormBuilder
    class FormBuilder < ActionView::Helpers::FormBuilder
      include RPH::FormAssistant::Helpers
      cattr_accessor :ignore_templates
      cattr_accessor :ignore_labels
      cattr_accessor :ignore_errors
      cattr_accessor :template_root
      
      # used if no other template is available
      attr_accessor_with_default :fallback_template, 'field'
      
      # if set to true, none of the templates will be used;
      # however, labels can still be automatically attached
      # and all FormAssistant helpers are still avaialable
      self.ignore_templates = false
      
      # if set to true, labels will become nil everywhere (both 
      # with and without templates)
      self.ignore_labels = false
      
      # set to true if you'd rather use #error_messages_for()
      self.ignore_errors = false

      # sets the root directory where templates will be searched
      # note: the template root should be nested within the
      # configured view path (which defaults to app/views)
      self.template_root = File.join(Rails.configuration.view_path, 'forms')
      
      # override the field_error_proc so that it no longer wraps the field
      # with <div class="fieldWithErrors">...</div>, but just returns the field
      ActionView::Base.field_error_proc = Proc.new { |html_tag, instance| html_tag }
      
    private
      # render(:partial => '...') doesn't want the full path of the template
      def self.template_root(full_path = false)
        full_path ? @@template_root : @@template_root.gsub(Rails.configuration.view_path + '/', '')
      end
      
      # get the error messages (if any) for a field
      def error_message_for(field)
        return nil unless has_errors?(field)
        errors = object.errors[field]
        [field.to_s.humanize, (errors.is_a?(Array) ? errors.to_sentence : errors).to_s].join(' ')
      end
      
      # returns true if a field is invalid
      def has_errors?(field)
        !(object.nil? || object.errors[field].blank?)
      end
      
      # checks to make sure the template exists
      def template_exists?(template)
        File.exists?(File.join(self.class.template_root(true), "_#{template}.html.erb"))
      end
      
    protected
      # renders the appropriate partial located in the template root
      def render_partial_for(element, field, label, tip, template, helper, args)
        errors = self.class.ignore_errors ? nil : error_message_for(field)
        locals = { :element => element, :label => label, :errors => errors, :tip => tip, :helper => helper }

        @template.render :partial => "#{self.class.template_root}/#{template}", :locals => locals
      end
      
      # render the element with an optional label (does not use the templates)
      def render_element(element, field, name, options, ignore_label = false)
        return element if ignore_label
        
        # need to consider if the shortcut label option was used
        # i.e. <%= form.text_field :title, :label => 'Project Title' %>
        text, label_options = if options[:label].is_a?(String)
          [options[:label], {}]
        else
          [options[:label].delete(:text), options.delete(:label)]
        end
        
        # consider trailing labels
        if %w(check_box radio_button).include?(name)
          label_options[:class] = (label_options[:class].to_s + ' inline').strip
          element + label(field, text, label_options)
        else
          label(field, text, label_options) + element
        end
      end
    
    public
      # redefining all traditional form helpers so that they
      # behave the way FormAssistant thinks they should behave
      send(:form_helpers).each do |name|
        define_method name do |field, *args|
          options, label_options = args.extract_options!, {}
          
          # consider the global setting for labels first
          options[:label] = false if self.class.ignore_labels
          
          # allow for turning labels off on a per-helper basis
          # <%= form.text_field :title, :label => false %>
          ignore_label = !!(options[:label].kind_of?(FalseClass))
          
          # ensure that the :label option is a Hash from this point on
          options[:label] ||= {}
          
          # allow for a cleaner way of setting label text
          # <%= form.text_field :whatever, :label => 'Whatever Title' %>
          label_options.merge!(options[:label].is_a?(String) ? {:text => options[:label]} : options[:label])

          # allow for a more convenient way to set common label options
          # <%= form.text_field :whatever, :label_id => 'dom_id' %>
          # <%= form.text_field :whatever, :label_class => 'required' %>
          # <%= form.text_field :whatever, :label_text => 'Whatever' %>
          %w(id class text).each do |option|
            label_option = "label_#{option}".to_sym
            label_options.merge!(option.to_sym => options.delete(label_option)) if options[label_option]
          end
          
          # build out the label element (if desired)
          label = ignore_label ? nil : self.label(field, label_options.delete(:text), label_options)

          # grab the template
          template = options.delete(:template) || name.to_s
          template = self.fallback_template unless template_exists?(template)

          # grab the tip, if any
          tip = options.delete(:tip)
          
          # call the original render for the element
          element = super(field, *(args << options))
          
          # return the helper with an optional label if templates are not to be used
          return render_element(element, field, name, options, ignore_label) if self.class.ignore_templates
          
          # render the partial template from the desired template root
          render_partial_for(element, field, label, tip, template, name, args)
        end
      end
      
      # Renders a partial, passing the form object as a local
      # variable named 'form'
      def partial(name, options={})
        (options[:locals] ||= {}).update :form => self
        options.update :partial => name
        @template.render options
      end
      
      # since #fields_for() doesn't inherit the builder from form_for, we need
      # to provide a means to set the builder automatically (works with nesting, too)
      #
      # Usage: simply call #fields_for() on the builder object
      #
      #   <% form_assistant_for @project do |form| %>
      #     <%= form.text_field :title %>
      #     <% form.fields_for :tasks do |task_fields| %>
      #       <%= task_fields.text_field :name %>
      #     <% end %>
      #   <% end %>
      def fields_for_with_form_assistant(record_or_name_or_array, *args, &proc)
        options = args.extract_options!
        # hand control over to the original #fields_for()
        fields_for_without_form_assistant(record_or_name_or_array, *(args << options.merge!(:builder => self.class)), &proc)
      end
      
      # used to intercept #fields_for() and set the builder
      alias_method_chain :fields_for, :form_assistant
    end
    
    # methods that mix into ActionView::Base
    module ActionView
      private
        # used to ensure that the desired builder gets set before calling #form_for()
        def form_for_with_builder(record_or_name_or_array, builder, *args, &proc)
          options = args.extract_options!
          # hand control over to the original #form_for()
          form_for(record_or_name_or_array, *(args << options.merge!(:builder => builder)), &proc)
        end
        
        # determines if binding is needed for #concat()
        # (Rails 2.2.0 and greater no longer requires the binding)
        def binding_required
          RPH::FormAssistant::Rules.binding_required?
        end
      
      public
        # easy way to make use of FormAssistant::FormBuilder
        #
        # <% form_assistant_for @project do |form| %>
        #   // fancy form stuff
        # <% end %>
        def form_assistant_for(record_or_name_or_array, *args, &proc)
          form_for_with_builder(record_or_name_or_array, RPH::FormAssistant::FormBuilder, *args, &proc)
        end
        
        # (borrowed the #fieldset() helper from Chris Scharf: 
        #   http://github.com/scharfie/slate/tree/master/app/helpers/application_helper.rb)
        #
        # <% fieldset 'User Registration' do %>
        #   // fields
        # <% end %>
        def fieldset(legend, &block)
          locals = { :legend => legend, :fields => capture(&block) }
          partial = render(:partial => "#{RPH::FormAssistant::FormBuilder.template_root}/fieldset", :locals => locals)
          
          # render the fields
          binding_required ? concat(partial, block.binding) : concat(partial)
        end
    end
  end   
end