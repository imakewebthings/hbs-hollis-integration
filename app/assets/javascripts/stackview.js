(function() {
  var urlBase = '/stackview';
  var $container = $();
  var ribbon, query, searchType, sort;

  function init() {
    $container.off();
    $container = $('.stackview-container');
    ribbon = $container.data('ribbon');
    query = $container.data('query');
    searchType = $container.data('searchtype');
    sort = $container.data('sort');

    $container.stackView({
      url: urlBase,
      ribbon: ribbon,
      search_type: searchType,
      query: query,
      items_per_page: 20,
      sort: sort
    });
  }

  $(document).on('ready page:load', init);
})();
