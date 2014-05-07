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
    if (location.href.indexOf('units') === -1) {
      $('#publication').empty().append($original);
    }
  }

  function normalizeData(data) {
    var normalized = $.extend(true, {}, data);
    var hollisBase = 'http://holliscatalog.harvard.edu/?itemid=|library/m/aleph|';
    var isHbs = data.collection === 'hbs_edu';
    var isHollis = data.collection === 'hollis_catalog';
    normalized.description = null;
    normalized.containing_book = null;
    normalized.hbs_url = null;
    normalized.hollis_url = null;
    normalized.pub_date = data.pub_date ? data.pub_date : null;
    normalized.creator = data.creator ? data.creator : [];
    normalized.topics = data.topic ? data.topic[0].split(';') : [];
    normalized.parameterize = parameterize;
    normalized.lcsh = data.lcsh ? data.lcsh : [];
    normalized.fmtclass = data.format.toLowerCase().replace(/ /g, '-');

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

    if ($.isArray(data.collection)) {
      if (data.url) {
        normalized.hbs_url = $.grep(data.url, function(url) {
          return url.match(/hbs\.edu/);
        })[0];
      }
      if (data.id_inst) {
        normalized.hollis_url = hollisBase + data.id_inst;
      }
    }
    else if (isHbs && data.url && data.url.length) {
      normalized.hbs_url = data.url[0];
    }
    else if (isHollis) {
      normalized.hollis_url = hollisBase + data.id_inst;
    }
    return normalized;
  }

  function renderPublication(data) {
    var template = $('#publication-template').html();
    $('#publication').html(window.tmpl(template, normalizeData(data)));
  }

  function requestItem(id) {
    $.get('http://hlslwebtest.law.harvard.edu/v2/api/item/' + id, function(data) {
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

  function rerenderPublication(event) {
    loadPublication($(this).data('stackid'));
  }

  $(window).on('hashchange.publication', checkHash);
  $document.on('stackview.init', '.stackview', checkHash);
  $document.on('stackview.pageload', '.stackview', highlight);
  $document.on('ready page:load', clearOriginal);
  $document.on('stackview.pageload', '.author-stack', saveAuthorTopics);
})();
