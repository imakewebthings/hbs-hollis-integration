(function() {
  var urlBase = '/stackview';
  var $container = $();
  var ribbon, author, searchType;

  function init() {
    $container.off();
    $container = $('.stackview-container');
    ribbon = $container.data('ribbon');
    author = $container.data('author');
    searchType = 'author';

    $container.stackView({
      url: urlBase,
      ribbon: ribbon,
      search_type: searchType,
      query: author,
      items_per_page: 20
    });
  }

  $(document).on('ready page:load', init);
})();
