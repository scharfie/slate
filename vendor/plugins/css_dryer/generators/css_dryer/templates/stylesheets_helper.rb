module StylesheetsHelper

  # Internet Exploder hacks.

  # <% ie6 do %>
  #   css for ie6 here
  # <% end %>
  def ie6(&block)
    wrap '* html', &block
  end

  # <% ie7 do %>
  #   css for ie7 here
  # <% end %>
  def ie7(&block)
    wrap '* + html', &block
  end

  # <% ie do %>
  #   css for ie here
  # <% end %>
  def ie(&block)
    ie6(&block) + ie7(&block)
  end

  # Self-clearing.  For example:
  #
  # <%= self_clear 'div#foo', 'img.bar', 'p ul' %>
  #
  # You can pass a hash as the final argument with these options:
  #   :clear => 'left' | 'right' | 'both' (default)
  def self_clear(*selectors)
    options = selectors.extract_options!
    clear = options[:clear] || 'both'

    selector_template = lambda { |proc| selectors.map{ |s| proc.call s }.join ', ' }

    p = lambda { |selector| "#{selector}:after" }
    q = lambda { |selector| "* html #{selector}" }
    r = lambda { |selector| "*:first-child+html #{selector}" }

    <<-END
    #{selector_template.call p} {
      content: ".";
      display: block;
      height: 0;
      clear: #{clear};
      visibility: hidden;
    }
    #{selector_template.call q} {
      height: 1%;
    }
    #{selector_template.call r} {
      min-height: 1px;
    }
    END
  end


  private

  # Wraps the block's output with +with+ and braces.
  # css_dryer will then de-nest the result when it
  # post-processes the result of the ERB evaluation.
  def wrap(with, &block)
    concat "#{with} {", block.binding
    yield
    concat "}\n", block.binding
  end
end
