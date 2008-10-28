(function($) {
  $.fn.associatedForm = function(options) {
    return this.each(function() {
      var $p = $(this)
      var $items = $p.find('.items')
      // build chain map
      var map = {};
      var blank = {};
      $items.find(":input[name*='" + options.path + "']").each(function() {
        if (this.type != 'file') {
          var key = this.name
          var value = key.replace(options.path, '').slice(1, -1)
          var index = value.indexOf('][')
          if (index < 0) {
            blank[value] = null
            map[":input[name='"+key+"']"]  = '{' + value + '}'
          }
        }
      })
  
      $items.chain($.extend(map, {
        builder: function() {
          var $$ = this;
          var builder = $items
          var count   = builder.items().length;
      
          if (typeof $.Chain.builderCallback == 'function') {
            $.Chain.builderCallback($$, options.path);  
          }
      
          $$.find('a.delete').click(function() {
            if (builder.items().length > 1) {
              $$.slideUp(function() { $$.remove() })
            }  
            return false
          }).end().find('a.new').click(function() {
            builder.items('add', blank); 
            return false    
          })
        }
      }));
  
      var items = options.items
      if (items.length == 0) { items = [blank] }
  
      $.each(items, function(index, item) {
        if (typeof item.id != 'undefined') $items.items('add', item);
      });
  
      var link = $('<a href="#"><span>Add</span></a>').click(function() {
        $items.items('add', blank); 
        return false
      })

      $p.parents('.fieldset').children('h3').append(link)

      $items.parents('form').submit(function() {
        var $$ = $items.find('.item').each(function(i) {
          $(this).find(':input').each(function() {
            this.name = this.name.replace('[]', '['+ i +']')
          })
        })
      })
    })  
  } // end function  
})(jQuery)  