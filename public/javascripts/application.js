// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function currentTime() {
  var d = new Date();
  var hour = d.getHours();
  var meridian = 'am';
  
  if (hour == 0) {
    hour = 12;
  } else if (hour > 12) {
    hour -= 12;
    meridian = 'pm';
  }
  
  var minutes = d.getMinutes();
  
  if (minutes < 10) minutes = '0' + minutes;
  
  return hour + ':' + minutes + ' ' + meridian; //.toUpperCase();
} // end currentTime

function prepareRequestHeader(xhr) {
  xhr.setRequestHeader("Accept", "text/javascript");
}

if (Animator) {
	Animator.prototype.stop = function() {
	  window.clearInterval(this.intervalId);
	  this.intervalId = null;
	} 
}