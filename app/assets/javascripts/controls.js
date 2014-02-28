(function() {
  var $document = $(document);

  $document.on('click', '.stackview-controls [name=collection]', function() {
    $('.stackview-container').data('collection', $(this).val());
    $document.trigger('stackview.reload');
  });
})();
