class InheritViewsTestController < ActionController::Base
  self.view_paths = [File.join(File.dirname(__FILE__), 'views_for_specs')]
end

# :a controller is a normal controller with inherit_views
# its subclasses will inherit its views
class AController < InheritViewsTestController
  inherit_views
  
  def render_non_existent_template
    render :action => 'non_existent'
  end
end

# :b controller is a normal controller with inherit_views 'a'
# It will inherit a's views, and its sublcasses will inherit its views ('b', then 'a')
class BController < InheritViewsTestController
  inherit_views 'a'
end

# :c cotroller is a subclass of :b controller, so it inheirt's b's views ('c', 'b', then 'a')
class CController < BController
end

# :d controller is a subclass of :a controller, with inherit_views 'other', so its views == ('d', 'other', then 'a')
class DController < AController
  inherit_views 'other'
end

# used to test normal rails behaviour
class NormalController < InheritViewsTestController
end

# used to test ActionMailer's use of views is not affected
class NormalMailer < ActionMailer::Base
  self.template_root = File.join(File.dirname(__FILE__), 'views_for_specs')

  def email
    recipients  'test@test.com'
    subject     'An email'
  end
end

# inherits views form normal mailer
class InheritingMailer < NormalMailer
  inherit_views 'normal_mailer'
end