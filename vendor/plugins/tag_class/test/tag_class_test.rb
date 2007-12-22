require 'test/unit'
require 'action_view'
require 'active_record'
require File.dirname($0) + '/../lib/tag_class.rb'
    
# dummy class to simulate an ActiveRecord model    
class Person
  attr_accessor :first_name, :last_name, :gender, :password, :id, :avatar
  def initialize(options={})
    options.each { |k,v| send((k.to_s + '=').to_sym, v) }
  end
end

class TagClassTest < Test::Unit::TestCase
  INPUT_TYPES = %w(text submit password checkbox radio)
  include ::ActionView::Helpers::TagHelper
  include ::ActionView::Helpers::FormHelper
  
  def test_tag
    INPUT_TYPES.each do |type|
      assert_equal "<input class=\"#{type}\" type=\"#{type}\" />", tag('input', :type => type)
      assert_equal "<input class=\"#{type}\" type=\"#{type}\" />", tag('input', :type => type, :class => type)
      assert_equal "<input class=\"custom #{type}\" type=\"#{type}\" />", tag('input', :type => type, :class => 'custom')
      assert_equal "<input class=\"custom #{type}\" type=\"#{type}\" />", tag('input', :type => type, :class => 'custom ' + type)
      assert_equal "<input class=\"custom-#{type} #{type}\" type=\"#{type}\" />", tag('input', :type => type, :class => 'custom-' + type)
    end
  end
  
  def test_form_building
    @person = Person.new(
      :first_name => 'Chris', 
      :last_name => 'Scharf', 
      :gender => 'M', 
      :password => 'secret',
      :avatar => '',
      :id => 17  
    )
    
    klass = ::ActionView::Helpers::InstanceTag
    
    assert_equal "<input class=\"text\" id=\"person_first_name\" name=\"person[first_name]\" size=\"30\" type=\"text\" value=\"Chris\" />", 
      klass.new(:person, :first_name, self, nil, @person).to_input_field_tag("text", :size => 30)
      
    assert_equal "<input class=\"password\" id=\"person_password\" name=\"person[password]\" size=\"30\" type=\"password\" value=\"secret\" />", 
      klass.new(:person, :password, self, nil, @person).to_input_field_tag("password", :size => 30)      

    assert_equal "<input class=\"hidden\" id=\"person_id\" name=\"person[id]\" type=\"hidden\" value=\"17\" />", 
      klass.new(:person, :id, self, nil, @person).to_input_field_tag("hidden")
      
    assert_equal "<input class=\"file\" id=\"person_avatar\" name=\"person[avatar]\" size=\"30\" type=\"file\" />", 
      klass.new(:person, :avatar, self, nil, @person).to_input_field_tag("file", :size => 30)       
      
    assert_equal "<input class=\"checkbox\" id=\"person_gender\" name=\"person[gender]\" type=\"checkbox\" value=\"yes\" />" +
                 "<input class=\"hidden\" name=\"person[gender]\" type=\"hidden\" value=\"no\" />", 
      klass.new(:person, :gender, self, nil, @person).to_check_box_tag({}, 'yes', 'no')      

    assert_equal "<input class=\"radio\" id=\"person_gender_male\" name=\"person[gender]\" type=\"radio\" value=\"male\" />", 
      klass.new(:person, :gender, self, nil, @person).to_radio_button_tag('male')  
  end
  
end
