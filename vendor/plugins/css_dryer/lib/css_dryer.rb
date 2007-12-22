require 'erb'

# Lifted from Rails.
# "", "   ", nil, [], and {} are blank
class Object  #:nodoc:
  def blank?
    if respond_to?(:empty?) && respond_to?(:strip)
      empty? or strip.empty?
    elsif respond_to?(:empty?)
      empty?
    else
      !self
    end
  end
end

# Converts DRY stylesheets into normal CSS ones.
module CssDryer

  VERSION = '0.1.5'

  class StyleHash < Hash  #:nodoc:
    attr_accessor :multiline
    def initialize *a, &b
      super
      multiline = false
    end
    def has_non_style_hash_children
      value.each { |elem|
        next if elem.kind_of? StyleHash
        return true unless elem.blank?
      }
      false
    end
    # We only ever have one key and one value
    def key
      self.keys.first
    end
    def key=(key)
      self.keys.first = key
    end
    def value
      self.values.first
    end
    def value=(value)
      self.values.first = value
    end
  end

  # Converts a stylesheet with nested styles into a flattened,
  # normal CSS stylesheet.  The original whitespace is preserved
  # as much as possible.
  #
  # For example, the following DRY stylesheet:
  #
  #   div {
  #     font-family: Verdana;
  #     #content {
  #       background-color: green;
  #       p { color: red; }
  #     }
  #   }
  #
  # is converted into this CSS:
  #
  #   div {
  #     font-family: Verdana;
  #   }
  #   div #content {
  #     background-color: green;
  #   }
  #   div #content p { color: red; }
  #
  # Note, though, that @media blocks are preserved.  For example:
  #
  #   @media screen, projection {
  #     div {font-size:100%;}
  #   }
  #
  # is left unchanged.
  #
  # Styles may be nested to an arbitrary level.
  def process(nested_css, indent = 2)  #:doc:
    # 'Normalise' comma separated selectors
    nested_css = factor_out_comma_separated_selectors(nested_css, indent)
    structure_to_css(nested_css_to_structure(nested_css), indent)
  end

  def nested_css_to_structure(css)  #:nodoc:
    # Implementation notes:
    # - the correct way to do this would be using a lexer and parser
    # - ironically there is a degree of repetition here
    document = []
    selectors = []
    media_block = false
    css.each do |line|
      depth = selectors.length
      case line.chomp!
      # Media block (multiline) opening - treat as plain text but start
      # watching for close of media block.
      # Assume media blocks are never themselves nested.
      # (This must precede the multiline selector condition.)
      when /^(\s*@media.*)[{]\s*$/
        media_block = true
        document << line if depth == 0
      # Media block inline
      # Assume media blocks are never themselves nested.
      when /^\s*@media.*[{].*[}]\s*$/
        document << line if depth == 0
      # Multiline selector opening
      when /^\s*([^{]*?)\s*[{]\s*$/
        hsh = StyleHash[ $1 => [] ]
        hsh.multiline = true
        if depth == 0
          document << hsh
        else
          prev_hsh = selectors.last
          prev_hsh.value << hsh
        end
        selectors << hsh
      # Neither opening nor closing - 'plain text'
      when /^[^{}]*$/
        if depth == 0
          document << line
        else
          hsh = selectors.last
          hsh.value << (depth == 1 ? line : line.strip)
        end
      # Multiline selector closing
      when /^([^{]*)[}]\s*$/
        if media_block
          media_block = false
          if depth == 0
            document << line
          else
            hsh = selectors.last
            hsh.value << line
          end
        else
          selectors.pop
        end
      # Inline selector
      when /^([^{]*?)\s*[{]([^}]*)[}]\s*$/
        key = (depth == 0 ? $1 : $1.strip)
        hsh = StyleHash[ key => [ $2 ] ]
        if depth == 0
          document << hsh
        else
          prev_hsh = selectors.last
          prev_hsh.value << hsh
        end
      end
    end
    document
  end

  def structure_to_css(structure, indent = 2)  #:nodoc:
    # Implementation note: the recursion and the formatting
    # ironically both feel repetitive; DRY them.
    indentation = ' ' * indent
    css = ''
    structure.each do |elem|
      # Top-level hash
      if elem.kind_of? StyleHash
        set_asides = []
        key = elem.key
        if elem.has_non_style_hash_children
          css << "#{key} {"
          css << (elem.multiline ? "\n" : '')
        end
        elem.value.each do |v|
          # Nested hash, depth = 1
          if v.kind_of? StyleHash
            # Set aside
            set_asides << set_aside(combo_key(key, v.key), v.value, v.multiline)
          else
            unless v.blank?
              css << (elem.multiline ? "#{v}" : v)
              css << (elem.multiline ? "\n" : '')
            end
          end
        end
        css << "}\n" if elem.has_non_style_hash_children
        # Now write out the styles that were nested in the above hash
        set_asides.flatten.each { |hsh|
          next unless hsh.has_non_style_hash_children
          css << "#{hsh.key} {"
          css << (hsh.multiline ? "\n" : '')
          hsh.value.each { |item|
            unless item.blank?
              css << (hsh.multiline ? "#{indentation}#{item}" : item)
              css << (hsh.multiline ? "\n" : '')
            end
          }
          css << "}\n"
        }
        set_asides.clear
      else
        css << "#{elem}\n"
      end
    end
    css
  end

  def set_aside(key, value, multiline)  #:nodoc:
    flattened = []
    hsh = StyleHash[ key => [] ]
    hsh.multiline = multiline
    flattened << hsh
    value.each { |val|
      if val.kind_of? StyleHash
        flattened << set_aside(combo_key(key, val.key), val.value, val.multiline)
      else
        hsh[key] << val
      end
    }
    flattened
  end
  private :set_aside

  def combo_key(branch, leaf)  #:nodoc:
    (leaf =~ /\A[.:#\[]/) ? "#{branch}#{leaf}" : "#{branch} #{leaf}"
  end
  private :combo_key

  def factor_out_comma_separated_selectors(css, indent = 2)  #:nodoc:
    # TODO: replace with a nice regex
    commas = false
    css.each do |line|
      next if line =~ /@media/
      next if line =~ /,.*;\s*$/    # allow comma separated style values
      commas = true if line =~ /,/
    end
    return css unless commas

    state_machine = StateMachine.new indent
    css.each { |line| state_machine.act_on line }
    factor_out_comma_separated_selectors state_machine.result
  end
  private :factor_out_comma_separated_selectors

  class StateMachine  #:nodoc:
    def initialize(indent = 2)
      @state = 'flow'
      @depth = 0
      @output = []
      @indent = ' ' * indent
    end
    def result
      @output.join
    end
    def act_on(input)
      # Implementation notes:
      # - the correct way to do this would be to use a lexer and parser
      if @state.eql? 'flow'
        case input
        when %r{/[*]}  # open comment
          @state = 'reading_comments'
          act_on input
        when /^[^,]*$/    # no commas
          @output << input
        when /,.*;\s*$/   # comma separated style values
          @output << input
        when /@media/     # @media block
          @output << input
        when /,/          # commas
          @state = 'reading_selectors'
          @selectors = []
          @styles = []
          act_on input
        end
        return

      elsif @state.eql? 'reading_comments'
        # Dodgy hack: remove commas from comments so that the
        # factor_out_comma_separated_selectors method doesn't
        # go into an infinite loop.
        @output << input.gsub(',', ' ')
        if input =~ %r{[*]/}   # close comment
          @state = 'flow'
        end
        return

      elsif @state.eql? 'reading_selectors'
        if input !~ /[{]/
          @selectors << extract_selectors(input)
        else
          @selectors << extract_selectors($`)
          @state = 'reading_styles'
          act_on input
        end
        return

      elsif @state.eql? 'reading_styles'
        case input
        when /\A[^{}]*\Z/           # no braces
          @styles << input
        when /\A[^,]*[{](.*)[}]/    # inline styles (no commas)
          @styles << (@depth == 0 ? $1 : input)
        when /[{](.*)[}]/           # inline styles (commas)
          @styles << $1
        when /[{][^}]*\Z/           # open multiline block
          @styles << input unless @depth == 0
          @depth += 1
        when /[^{]*[}]/             # close multiline block
          @depth -= 1
          @styles << input unless @depth == 0
        end
        if @depth == 0 && input =~ /[}]/
          @selectors.flatten.each { |selector|
            # Force each style declaration onto a new line.
            @output << "#{selector} {\n"
            @styles.each { |style| @output << "#{@indent}#{style.chomp.strip}\n" }
            @output << "}\n"
          }
          @state = 'flow'
        end
        return

      end
    end
    
    def extract_selectors(line)
      line.split(',').map { |selector| selector.strip }.delete_if { |selector| selector =~ /\A\s*\Z/ }
    end
    private :extract_selectors

  end

  # Handler for DRY stylesheets which can be registered with Rails
  # as a new templating system.
  #
  # DRY stylesheets are piped through ERB and then CssDryer#process.
  class NcssHandler
    include CssDryer
    include ERB::Util

    def initialize(view)
      @view = view
    end

    # The filepath parameter is there only for compatibility with Markaby.
    # It is not used.
    def render(template, assigns, filepath = nil)
      # Based on Agile Web Development With Rails v2, p.520
      
      # Create an anonymous object and get its binding
      env = Object.new
      bind = env.send :binding

      # Add in the instance variables from the view
      @view.assigns.each do |k, v|
        env.instance_variable_set "@#{k}", v
      end

      # And local variables if we're a partial
      assigns.each do |k, v|
        eval "#{k} = #{v}", bind
      end

      @view.controller.headers["Content-Type"] ||= 'text/css'

      # Evaluate with ERB
      dry_css = ERB.new(template).result(bind)
      
      # Flatten
      process(dry_css)
    end
  end
end
