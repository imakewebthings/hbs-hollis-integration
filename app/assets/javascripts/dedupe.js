(function() {
  var $document = $(document);
  var $previous, $stack;

  function init() {
    $stack = $('.stackview');
    $previous = null;
  }

  function stringSubset(a, b) {
    return a.indexOf(b) > -1 || b.indexOf(a) > -1;
  }

  function dedupe() {
    $('.stack-item:not(.deduped)').each(function() {
      if ($previous) {
        var $current = $(this);
        var currentData = $current.data('stackviewItem');
        var year = currentData.pub_date_numeric;
        var title = currentData.title.toLowerCase();
        var previousData = $previous.data('stackviewItem');
        var previousYear = previousData.pub_date_numeric;
        var previousTitle = previousData.title.toLowerCase();

        $previous.addClass('deduped');
        if (stringSubset(previousTitle, title) && previousYear === year) {
          $previous.addClass('duplicate');
        }
      }
      $previous = $(this);
    });
  }

  $document.on('stackview.init', init);
  $document.on('stackview.pageload', dedupe);
})();
