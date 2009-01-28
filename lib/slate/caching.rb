module Slate
  module Caching
    def self.cache_path_for_domain(domain)
      Rails.public_path / 'cache' / domain
    end
    
    def self.expire_cache_for_space(space, *paths)
      space.domains.each do |e|
        base = cache_path_for_domain(e.name)
        entries = paths.map { |path| Dir.glob(base / path) }.flatten
        FileUtils.rm_f(entries)
      end
    end
    
    def self.expire_page(page)
      return if page.nil?
      paths = page.permalinks.map { |path| path.to_s + '.html' }
      paths << 'index.html' if page.is_default?
      expire_cache_for_space @space, paths
    end
  end
end