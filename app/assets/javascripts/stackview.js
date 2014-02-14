(function() {
  var urlBase = '/stackview';
  var $container = $();
  var ribbon, query, searchType;

  function init() {
    $container.off();
    $container = $('.stackview-container');
    ribbon = $container.data('ribbon');
    query = $container.data('query');
    searchType = $container.data('searchtype');

    $container.stackView({
      url: urlBase,
      ribbon: ribbon,
      search_type: searchType,
      query: query,
      items_per_page: 20
    });
  }

  $(document).on('ready page:load', init);
})();
