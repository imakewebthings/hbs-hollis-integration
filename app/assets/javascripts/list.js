(function() {
  $(document).on('ready page:load', function() {
    var $list = $('.search-list ul');
    var $active = $list.find('.active');

    if ($list.length && $active.length) {
      $list.scrollTop($active.offset().top - $list.offset().top);
    }
  });
})();
