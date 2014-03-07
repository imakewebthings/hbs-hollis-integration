(function() {
  var $document = $(document);
  var originalQuery, coauthorQuery, $stack, originalRibbon;

  function init() {
    $stack = $('.stackview');
    originalQuery = $stack.data('query');
    coauthorQuery = $stack.data('coauthorquery');
    originalRibbon = $stack.data('ribbon');
  }

  $document.on('ready page:load', init);
  $document.on('click', 'input.coauthors', function() {
    var checked = $(this).is(':checked');
    var ribbonText = originalRibbon;
    var query = originalQuery;
    if (checked) {
      ribbonText += ' and Coauthors';
      query = coauthorQuery
    }
    $stack.data('query', query);
    $stack.data('ribbon', ribbonText);
    $document.trigger('stackview.reload');
  });
})();
