function editArea() {
  var width = 500;
  var height = 400;	
	
	var parameters = [
	  "width=" + width, 
	  "height=" + height,
	  "resizable=yes"
  ].join(',')

	var w = window.open(this.href, 'b-area', parameters);
	w.focus();
	return false;
}

function updateAreaOnPage(dom_id) {
	var page = window.opener.document;
	var area = page.getElementById(dom_id);
	$(area).html($('#area').html());
}

$(function() {
	$('a.b-area').click(editArea)
	$('body').css({marginTop: $('#b-toolbar')[0].offsetHeight})
});