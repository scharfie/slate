class Theme < ActiveRecord::Base
  attr_accessor :type
  attr_accessor :url
  attr_accessor :name

  def self.find(*args)
    nil
  end
  
  def self.columns(*args)
    []
  end
  
  def name
    File.basename(url, '.git')
  end
  
  def install
    `git clone #{url} #{Rails.public_path / 'themes' / name}`
  end
end