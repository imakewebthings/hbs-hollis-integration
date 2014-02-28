(function() {
  var urlBase = '/stackview';
  var $container = $();
  var ribbon, query, searchType, sort, collection;

  function init() {
    $container.off();
    $container.removeData('stackviewObject');
    $container = $('.stackview-container');
    ribbon = $container.data('ribbon');
    query = $container.data('query');
    searchType = $container.data('searchtype');
    sort = $container.data('sort');
    collection = $container.data('collection');

    $container.stackView({
      url: urlBase,
      ribbon: ribbon,
      search_type: searchType,
      query: query,
      items_per_page: 20,
      sort: sort,
      collection: collection
    });
  }

  $(document).on('ready page:load stackview.reload', init);
})();
