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