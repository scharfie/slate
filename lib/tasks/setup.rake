namespace :slate do
  desc "Setup slate with an initial user and space"
  task :setup do
    Rake::Task['slate:setup:user'].invoke
    Rake::Task['slate:setup:directories'].invoke
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
    
    desc "Creates directories expected by slate"
    task :directories do
      path = "#{Rails.root}/public/themes"
      FileUtils.mkdir_p(path) unless File.directory?(path)
    end
  end
end