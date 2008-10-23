(function($) {
  $.fn.faded = function(options) {
    return this.each(function() {
      var $$ = $(this)
      if (options.left)  $$.append('<div class="white-fade-left"></div>')
      if (options.right) $$.append('<div class="white-fade-right"></div>')
    })
  }
})(jQuery)