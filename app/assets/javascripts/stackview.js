(function() {
  var urlBase = '/stackview';

  function init() {
    var $container = $('.stackview-container');
    var ribbon = $container.data('ribbon');
    var author = $container.data('author');
    var searchType = 'author';

    $container.stackView({
      url: urlBase,
      ribbon: ribbon,
      search_type: searchType,
      query: author
    });
  };

  $(document).on('ready page:load', init);
})();
