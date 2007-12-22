// AreaEditor object
AreaEditor = {
  baseURL: '',
  pageID: null,
  areaKey: null,
  effects: {
    autosave: null,
    unsaved: null
  },
  preview: null,
  autosaveStatus: null
};

// initializes the AreaEditor -- note that
// there can be only one
AreaEditor.initialize = function(options) {
  this.windowHeight = window.innerHeight;
  this.panelBodies = {};
  this.panelHeight = this.windowHeight - $('#draft .body')[0].offsetTop;
  this.expanded = $('#draft')[0];
  this.dirty = false;
  this.autosaveStatus = $('#autosaveStatus');
  this.previewBody = $('#previewBody');
  
  $.extend(this, options);    
  
  this.effects.autosave = new Animator({ duration: 3000 });
  this.effects.autosave.addSubject(new CSSStyleSubject(
    this.autosaveStatus[0], 'color: #FC0', 'color: #888')
  );

  this.effects.unsaved = new Animator({ duration: 100 });
  this.effects.unsaved.addSubject(new CSSStyleSubject(
    this.autosaveStatus[0], 'color: #F66')
  );

  this.initPanels();
  this.doResize();
  this.enableAutosave();
  
  $(window).bind('resize', this.doResize);
}

// copies the content from the given version
// to draft and displays the draft panel
AreaEditor.copyToDraft = function(version) {
  var src = '#version-' + version + '-tx';
  $('#area_body')[0].value = $(src)[0].value;
  this.runAccordion($('#draft'));
  this.autosaveStatus.html("Copied content from version " + version);
  this.effects.autosave.play();
}

// AJAX call to /update or /create which saves
// the draft (only saves if the dirty flag is set
// or if force is set to true)
AreaEditor.save = function(force) {
	var ae = AreaEditor;
  if (!ae.dirty && !force) return;
  
  var params = $('#draft form').serializeArray();
  params.push({commit: 'Save now'});
  
  $.ajax({
    url: ae.baseURL, 
    type: 'POST', 
    data: params, 
    dataType: 'script',
    beforeSend: prepareRequestHeader
  });
}

// AJAX call to /version to update the 
// given panel with content
AreaEditor.loadPanel = function(panel) {
  var m = panel.id.match(/version-(\d+)/);
  var version = m[1];
  
  $.get(this.baseURL + '/version',
    { version: version },
    function(response) { 
      $(panel).find('.content').html(response); 
      panel.loaded = true; 
    }
  );
} // end loadPanel

// AJAX call to /preview to update the
// preview panel
AreaEditor.preview = function() {
  var params = $.map($('#draft form').serializeArray(), function(i) {
    return (i.name == '_method') ? null : i;
  });
  
  $.ajax({
    url: this.baseURL + '/preview',
    type: 'POST', 
    data: params, 
    dataType: 'script',
    beforeSend: prepareRequestHeader
  });
} // end showPreview()

// updates area, preview panel, and area on page
AreaEditor.updatePreview = function(html) {
	$('#area').html(html);
  this.previewBody.html($('#area .b-content').html());
  this.updateAreaOnPage();
}

// called after AJAX to /preview
// fixes the preview panel height and displays it
AreaEditor.afterPreview = function() {
	this.previewBody.height(this.panelHeight - 100);
	
  $('#draft').hide();
  $('#preview').show();
}

// sets the dirty flag, updates the autosave status
// and enables the autosave timer
AreaEditor.markUnsaved = function(force) {
  if (this.dirty && !force) return;
  this.dirty = true; 
  this.enableAutosave();
  
  this.autosaveStatus.html('Unsaved as of ' + currentTime());

  this.effects.autosave.stop();
  this.effects.unsaved.play();
}

// called after AJAX to /update or /create
AreaEditor.afterSave = function(status) {
	this.autosaveStatus.html(status);
  this.dirty = false;
  this.effects.autosave.play();
  this.enableAutosave();
}

// hides the preview and shows the draft
AreaEditor.closePreview = function() {
  $('#draft').show();
  $('#preview').hide();
  this.doResize();
}

// initializes all accordion panels
AreaEditor.initPanels = function() {
  var ae = this;
  $('div.panel').each(function(index) {
    var panel = $(this);
    var h2 = panel.find('h2');
    if (panel[0].id == 'preview') {
      panel.bind('dblclick', function() { ae.closePreview(); });
      h2.bind('click', function() { ae.closePreview(); });
    } else {  
      h2.bind('click', function() { ae.runAccordion(panel) });
    }
  
    panel[0].loaded = !panel[0].id.match(/version-(\d+)/);
    ae.panelBodies[panel[0].id] = panel.find('.body')[0];
  });
}

// resizes accordion when window resizes
AreaEditor.doResize = function() {
  var ae = AreaEditor;
  var nwindowHeight = window.innerHeight;
  var deltaHeight = ae.windowHeight - nwindowHeight;
  
  // store new heights
  ae.windowHeight = nwindowHeight;
  ae.panelHeight -= deltaHeight;
  
  if (ae.expanded.id == 'draft') {
    if (ae.expanded.style.display != 'none') {
      // var editor = $('#area_body')[0];
      // var editorActions = $('#actions_for_draft')[0];
      // editor.style.height = windowHeight - editor.offsetTop - editorActions.offsetHeight - 22 + 'px';
    } else {
      var preview = $('#previewBody')[0];
      preview.style.height = ae.panelHeight - 102 + 'px';
    }  // end if hidden
  } // end if draft
  
  var b = ae.panelBodies[ae.expanded.id];
  var c = $(ae.expanded).find('.content')[0];
  b.style.height = ae.panelHeight - 2 + 'px'; //parseInt(b.style.height) - deltaHeight + 'px';
  c.style.height = ae.panelHeight - 102 + 'px';
} // end doResize

// updates area on page (if available)
AreaEditor.updateAreaOnPage = function() {
  if (window.opener != null) {
	  window.opener.document.getElementById(
		  'area-' + this.pageID + '-' + this.areaKey
		).innerHTML = $('#area').html();
	} // end if	
} // end updatePreviewOnPage

// enables auto-saving feature
AreaEditor.enableAutosave = function() {
  if (this.autosaveTimer) {
    window.clearTimeout(this.autosaveTimer);
    this.autosaveTimer = null;
  } 
  
  this.autosaveTimer = window.setTimeout(this.save, 60000);
}

// creates and executes the accordion animation
// and displays the given panel
AreaEditor.runAccordion = function(panel) {
  panel = $(panel)[0];
  
  if (panel == this.expanded) { 
    if (panel.id == 'draft') return; 
    panel = $('#draft')[0];
  }      
  
  if (panel.loaded == false) {
    this.loadPanel(panel);
  }
  
  current_panel = this.panelBodies[panel.id];
  prev_panel    = this.panelBodies[this.expanded.id];

  var ae = this;
  var effects = new Animator({
    duration: 600,
    transition: Animator.makeEaseOut(2),
    onComplete: ae.doResize
  });
      
  //var h = prev_panel.offsetHeight;
  var h = this.panelHeight - 2;
  effects.addSubject(new CSSStyleSubject(current_panel, 'height: ' + h + 'px'));
  effects.addSubject(new CSSStyleSubject(prev_panel,    'height: 0;'));
  
  if (panel.id != 'panelDraft')
    effects.addSubject(new CSSStyleSubject($('#' + panel.id + ' .content')[0], 'height: ' + (h-100) + 'px; overflow: auto;'));
  if (this.expanded.id != 'panelDraft')
    effects.addSubject(new CSSStyleSubject($('#' + this.expanded.id + ' .content')[0], 'height: 0; overflow: hidden;'));
  
  this.closePreview();
  effects.play();
      
  this.expanded = panel;
}