(function() {
  var $document = $(document);
  var $previous, $stack;

  function init() {
    $stack = $('.stackview');
    $previous = null;
  }

  function stringSubset(a, b) {
    return a.indexOf(b) > -1 || b.indexOf(a) > -1;
  }

  function concatData(source, target) {
    $.each(['url', 'lcsh'], function(i, prop) {
      source[prop] = source[prop] || [];
      target[prop] = target[prop] || [];
      target[prop] = target[prop].concat(source[prop]);
      $.unique(target[prop]);
    });

    $.each([source, target], function(i, obj) {
      if (!$.isArray(obj.source_record.collection)) {
        obj.source_record.collection = [obj.source_record.collection];
      }
    });
    target.source_record.collection = target.source_record.collection.concat(
      source.source_record.collection
    );
    $.unique(target.source_record.collection);

    if (source.topic[0].length === 1) {
      console.log('oops');
    }
    target.topic = target.topic || [];
    target.topic[0] = target.topic[0] ? target.topic[0].split(';') : [];
    source.topic = source.topic || [];
    var sourceTopic = source.topic[0] ? source.topic[0].split(';') : [];
    var targetTopic = target.topic[0].concat(sourceTopic).join(';');
    target.topic = targetTopic ? [targetTopic] : null;
  }

  function updateRendering($current, currentData) {
    var isHbs = !!$.grep(currentData.source_record.collection, function(c) {
      return c === 'hbs_edu';
    }).length;
    var isHollis = !!$.grep(currentData.source_record.collection, function(c) {
      return c === 'hollis_catalog';
    }).length;
    $current.attr({
      'data-hbs': isHbs,
      'data-hollis': isHollis
    });
  }

  function dedupe() {
    $('.stack-item:not(.deduped)').each(function() {
      if ($previous) {
        var $current = $(this);
        var currentData = $current.data('stackviewItem');
        var year = currentData.pub_date_numeric;
        var title = currentData.title.toLowerCase();
        var previousData = $previous.data('stackviewItem');
        var previousYear = previousData.pub_date_numeric;
        var previousTitle = previousData.title.toLowerCase();

        title = title.replace('&', '').replace('and', '');
        previousTitle = previousTitle.replace('&', '').replace('and', '');

        $previous.addClass('deduped');
        if (stringSubset(previousTitle, title) && previousYear === year) {
          concatData(previousData, currentData);
          $previous.addClass('duplicate');
          updateRendering($current, currentData);
        }
      }
      $previous = $(this);
    });
  }

  $document.on('stackview.init', init);
  $document.on('stackview.pageload', dedupe);
})();
