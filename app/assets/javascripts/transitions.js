(function() {
  $(document)
    .on('click', '.search-by a', function() {
      $('.fat-inner p').slideUp();
      $('main').animate({ opacity: 0.3 });
    })
    .on('click', '.search-list a', function() {
      $('.stackview-container, #publication').animate({ opacity: 0.3 });
      $('.search-by:not(header .search-by)').slideUp();
    })
    .on('click', '.stack-item:not(.active)', function() {
      $('.publication-container').animate({ opacity: 0.3 });
    })
    .on('page:restore', function() {
      $('.fat-inner p, .search-by:not(header .search-by)').slideDown();
      $('.stackview-container, #publication').css('opacity', 1);
    });
})();
