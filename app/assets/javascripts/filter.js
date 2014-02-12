(function() {
  var $filterBox = $();
  var $style;

  function renderStyle(term) {
    return [
      '.search-list li { display:none; }',
      '.search-list li[data-name*="',
      term,
      '"] { display:block; }'
    ].join('');
  }

  function init() {
    $filterBox.off('change.filter keyup.filter');
    $filterBox = $('.search-list input');
    $style = $('#filter-css');
    $filterBox.on('change.filter keyup.filter', function() {
      var term = $(this).val();
      var rule = term ? renderStyle(term) : '';
      $style.text(rule);
    });
  }

  $(document).on('ready page:load', init);
})();
