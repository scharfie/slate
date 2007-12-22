module Slate
  class Collectible
    # hash of all items organized by key
    attr_accessor :items
    
    # stack of keys for this collectible
    # Example usage:
    #   collectible = Collectible.new('abc')
    #   collectible.key # => 'abc'
    #   collectible.keys.push 'def'
    #   collectible.key # => 'def'
    #   collectible.keys.pop
    #   collectible.key # => 'abc'
    attr_accessor :keys
    
    # initializes new Collectible with given key
    def initialize(default_key=nil)
      @items = HashWithIndifferentAccess.new { |hash, key| hash[key] = [] }
      @keys  = [default_key.to_s].compact
      @items[default_key.to_s] = [] unless default_key.nil?
    end
    
    # returns the key from the top of keys stack
    def key
      @keys.last or raise "No key specified for collectible! (#{__FILE__}, #{__LINE__})"
    end
    
    # adds new item to the collection for the given key
    # (defaults to the current key)
    def push(key=nil, content=nil, &block)
      content, key = key, self.key if content.nil?
      (content ||= '') << block.call if block_given?
      (@items[key] ||= []) << content
    end
    
    # returns the items for the given key
    # (defaults to the current key)
    def items(key=nil)
      @items[key || self.key]
    end
  end
end