module App
  module ClassMethods
    # production environment?
    def production?
      RAILS_ENV == 'production'  
    end
    
    # development environment?
    def development?
      RAILS_ENV == 'development'
    end
    
    # test environment?
    def test?
      RAILS_ENV == 'test'
    end
    
    # root path for application
    def root
      RAILS_ROOT
    end  
  end
  
  extend ClassMethods  
end