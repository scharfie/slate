require 'highline'

namespace :slate do
  desc "Setup slate with an initial user and space"
  task :setup do
    Rake::Task['slate:setup:user'].invoke
  end
  
  task :verify_schema => :environment do
    schema_version = begin
      ActiveRecord::Base.connection.execute('SELECT * FROM schema_migrations')
    rescue
      0
    end
    
    raise "Please create your database and migrate first." if schema_version == 0
  end
  
  namespace :setup do
    desc "Creates a new (super)user"
    task :user => 'slate:verify_schema' do
      user = User.new
      console = Console.new
      
      console.banner "Setup - create superuser"
      console.say "Let's create a new superuser.  We'll need a few pieces of information."
      
      loop do
        user.super_user = true
        
        console.field user, :first_name, "First, we need your name:"
        console.field user, :last_name
        console.field user, :username, "Now, please enter the username for this new user:"

        message = "Next, we need a password.  "
        console.field(user, :password, message) { |q| q.echo = '*' }
        console.field(user, :password_confirmation, "Please confirm your password:") {|q| q.echo = '*'}
        console.field user, :email_address, "Finally, please enter an email address.  This address should be valid - the system will send emails to this address for certain events."
        
        break if user.save
        
        console.say_with_color "\nHmm, something's not right...", :warning
        user.errors.each_full { |e| console.warning e }
      end
      
      console.notice "\nSuperuser '#{user.username}' created!\n"
    end
  end
end

class Console < HighLine
  def initialize(*args)
    super

    self.class.color_scheme = ::HighLine::ColorScheme.new do |cs|
      cs[:label] = [:bold, :yellow]
      cs[:warning] = [:bold, :red]
      cs[:notice] = [:bold, :green]
    end
  end
  
  def banner(text)
    say('=' * 70)
    say(text)
    say('=' * 70)
  end
  
  def say_with_color(msg, color)
    say color(msg, color)
  end
  
  def label(msg)
    say_with_color "\n" + msg + "\n", :label
  end
  
  def warning(msg)
    say_with_color '  -  ' + msg, :warning
  end
  
  def text_field(msg, &block)
    msg += ':'
    ask(" =>  #{msg.ljust(12)} ", &block)
  end
  
  def notice(msg)
    say_with_color msg, :notice
  end
  
  def field(object, field, message=nil, &block)
    field = field.to_s
    attribute = field.gsub '_confirmation', ''
    
    loop do
      label message unless message.nil?
      object.send field + '=', text_field(field.humanize, &block)
      object.valid?
    
      break if (errors = object.errors.on(attribute)).blank?
      errors.each { |m| warning attribute.humanize + ' ' + m }
    end        
  end
end