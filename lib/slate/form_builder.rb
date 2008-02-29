module Slate
  # Slate::FormBuilder is used to create forms in a consistent manner
  # It is based on the excellent TemplatedFormBuilder plugin
  # by Moritz Heidkamp (http://tpl-formbuilder.rubyforge.org/).
  # 
  # However, the following changes were made:
  #   - added support for a :tip argument
  #   - added actions helper which creates <div class="actions"></div>
  #     (used for submit tags)
  class FormBuilder < ActionView::Helpers::FormBuilder
    attr_accessor_with_default :default_template, 'element'
    attr_accessor_with_default :label_append, ''
        
    # redefine the field helpers 
    (field_helpers + %w(date_select datetime_select collection_select select submit)).each do |helper|
      define_method(helper) do |*args|
        args << Hash.new unless Hash === args.last

        label = args[-1].delete(:label) { args.first.to_s.humanize }
        tip   = args[-1].delete(:tip)

        template = args.last.has_key?(:template) ? args.last.delete(:template) : self.default_template

        return super(*args) unless template

        render_form_element helper, label, tip, template, args, super(*args)
      end
    end

  private
    # renders the form element using partials from forms/
    def render_form_element(helper, label, tip, template, helper_args, element)
      locals = {
        :label => label_for(helper_args.first, label),
        :element => element,
        :tip => tip,
        :helper => helper,
        :errors => @template.error_message_on("#{@object_name}","#{helper_args[0]}", helper_args[0].to_s.humanize + ' ')
      }

      begin
        @template.render :partial => "forms/#{template || helper}", :locals => locals
      rescue ActionView::ActionViewError
        @template.render :partial => "forms/#{self.default_template || 'element'}", :locals => locals
      end
    end

  public
    # generates a label element for given method of 
    # current object, using the given label for text
    def label_for(method, label)
      return '' if label.nil?
      label += (self.label_append || '') unless label =~ /\?$/
      @template.content_tag('label', label, {:for => "#{@object_name}_#{method}"})
    end
    
    # surrounds the given block in a DIV with class 'actions'
    def actions(&block)
      @template.concat '<div class="actions">' + 
        @template.capture(&block) +
      '</div>', block.binding
    end
  end
end