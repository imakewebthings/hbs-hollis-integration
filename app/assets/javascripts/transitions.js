(function() {
  $(document)
    .on('click', '.search-by a', function() {
      $('main').animate({ opacity: 0.2 });
    })
    .on('click', '.search-list a', function() {
      $('.stackview-container, #publication').animate({ opacity: 0.2 });
    })
    .on('click', '.stack-item:not(.active)', function() {
      $('.publication-container').animate({ opacity: 0.2 });
    })
    .on('page:restore', function() {
      $('.stackview-container, #publication, main').animate({ opacity: 1 });
    });
})();
