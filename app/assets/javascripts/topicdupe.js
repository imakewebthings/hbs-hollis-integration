(function() {
  var $document = $(document);

  function loadItem($target, targetData) {
    var base = 'http://hlslwebtest.law.harvard.edu/v2/api/item?filter=id_inst:';
    $.get(base + targetData.rsrc_value, function(data) {
      var itemData = data.docs[0];
      if (itemData) {
        window.StackView.utils.concatData(itemData, targetData);
        window.StackView.utils.updateRendering($target, targetData);
        targetData.id_inst = itemData.id_inst;
      }
    }, 'jsonp');
  }

  function loadDupes() {
    $('.stack-item:not(.topicduped)').each(function() {
      var $current = $(this);
      var currentData = $current.data('stackviewItem');

      if (currentData.rsrc_key === 'Harvard catalog') {
        loadItem($current, currentData);
      }
    });
  }

  $document.on('stackview.pageload', '[data-searchtype="topic"]', loadDupes);
})();
