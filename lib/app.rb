module App
  module ClassMethods
    # production environment?
    def production?
      Rails.env == 'production'  
    end
    
    # development environment?
    def development?
      Rails.env == 'development'
    end
    
    # test environment?
    def test?
      Rails.env == 'test'
    end
    
    # root path for application
    def root
      Rails.root
    end  
  end
  
  extend ClassMethods  
end