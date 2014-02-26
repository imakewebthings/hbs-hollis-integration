(function() {
  $(document)
    .on('click', '.search-by a', function(event) {
      $('.fat-inner p').slideUp();
      $('main').animate({ opacity: 0.3 });
    })
    .on('click', '.search-list a', function(event) {
      $('.stackview-container, #publication').animate({ opacity: 0.3 });
    })
    .on('click', '.stack-item', function(event) {
      $('.publication-container').animate({ opacity: 0.3 });
    });
})();
