(function() {
  var $document = $(document);
  var lastId, $original;

  function parameterize(str) {
    return str
      .replace(/[^-\w\s]/g, '')
      .trim()
      .replace(/[-\s]+/g, '-')
      .toLowerCase();
  }

  function unloadPublication() {
    $('#publication').empty().append($original);
  }

  function normalizeData(data) {
    var normalized = $.extend(true, {}, data);
    normalized.description = null;
    normalized.containing_book = null;
    normalized.url = data.url && data.url.length ? data.url[0] : null;
    normalized.pub_date = data.pub_date ? data.pub_date : null;
    normalized.creator = data.creator ? data.creator : [];
    normalized.topics = data.topic ? data.topic[0].split(';') : [];
    normalized.parameterize = parameterize;
    normalized.lcsh = data.lcsh ? data.lcsh : [];
    if (data.note) {
      $.each(data.note, function(i, note) {
        var cbMatch = note.match(/containing_book:(.*)/);
        if (cbMatch) {
          normalized.containing_book = cbMatch[1];
        }
        if (!cbMatch && i === data.note.length - 1) {
          normalized.description = note;
        }
      });
    }
    return normalized;
  }

  function renderPublication(data) {
    var template = $('#publication-template').html();
    $('#publication').html(window.tmpl(template, normalizeData(data)));
  }

  function requestItem(id) {
    $.get('http://librarycloud.harvard.edu/v1/api/item/' + id, function(data) {
      var itemData = data.docs[0];
      if (itemData) {
        renderPublication(itemData);
      }
    }, 'jsonp');
  }

  function loadPublication(id) {
    var $stackItem = $('.stack-item[data-stackid=' + id + ']');
    if ($stackItem.length) {
      renderPublication($stackItem.data('stackviewItem'));
    }
    else {
      requestItem(id);
    }
  }

  function highlight() {
    $('.stack-item').removeClass('active');
    $('.stack-item[data-stackid="' + lastId + '"]').addClass('active');
  }

  function authorTopics() {
    var topicHash = {};
    var topics = [];

    $('.stack-item:not(.duplicate)').each(function() {
      var item = $(this).data('stackviewItem');
      var itemTopics = item && item.topic;
      if (itemTopics) {
        itemTopics = itemTopics[0].split(';')
        $.each(itemTopics, function(i, topic) {
          topicHash[topic] = 1;
        });
      }
    });
    $.each(topicHash, function(key, val) {
      topics.push(key);
    });

    return {
      name: $('.ribbon').text(),
      bio: $('.stackview').data('bio'),
      topics: topics,
      parameterize: parameterize
    }
  }

  function saveOriginal() {
    $original = $('#publication').contents();
  }

  function saveAuthorTopics() {
    if (!$original) {
      $original = window.tmpl($('#author-topics').html(), authorTopics());
      if (!lastId) {
        unloadPublication();
      }
    }
  }

  function clearOriginal() {
    $original = null;
  }

  function checkHash() {
    var id = location.hash.split('#')[1];

    if (!$original) {
      saveOriginal();
    }

    if (id && id != lastId) {
      loadPublication(id);
    }
    else if (!id) {
      unloadPublication();
    }
    lastId = id;
    highlight();
  }

  $(window).on('hashchange.publication', checkHash);
  $document.on('stackview.init', '.stackview', checkHash);
  $document.on('stackview.pageload', '.stackview', highlight);
  $document.on('ready page:load', clearOriginal);
  $document.on('stackview.pageload', '.author-stack', saveAuthorTopics);
})();
