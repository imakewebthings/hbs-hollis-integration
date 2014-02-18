(function() {
  var lastId;

  function unloadPublication() {
    $('#publication').empty();
  }

  function renderPublication(data) {
    var template = $('#publication-template').html();
    $('#publication').html(window.tmpl(template, data));
  }

  function requestItem(id) {
    $.get('http://librarycloud.harvard.edu/v1/api/item/' + id, function(data) {
      var itemData = data.docs[0];
      if (itemData) {
        renderPublication(itemData);
      }
    }, 'jsonp');
  }

  function loadPublication(id) {
    var $stackItem = $('.stack-item[data-stackid=' + id + ']');
    if ($stackItem.length) {
      renderPublication($stackItem.data('stackviewItem'));
    }
    else {
      requestItem(id);
    }
  }

  function highlight() {
    $('.stack-item').removeClass('active');
    $('.stack-item[data-stackid="' + lastId + '"]').addClass('active');
  }

  function checkHash() {
    var id = location.hash.split('#')[1];
    if (id && id != lastId) {
      loadPublication(id);
    }
    else if (!id) {
      unloadPublication();
    }
    lastId = id;
    highlight();
  }

  $(window).on('hashchange.publication', checkHash);
  $(document)
    .on('stackview.init', '.stackview', checkHash)
    .on('stackview.pageload', '.stackview', highlight);
})();
