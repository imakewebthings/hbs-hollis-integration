(function($, window, undefined) {
	/*
	   Extend StackView defaults to include options for this item type.

	   max_height_percentage
	      Books with the maximum height will render as this percentage
	      width in the stack.

	   max_height
		    The maximum height in centimeters that an item will render as,
		    regardless of the true height of the item.

		 max_pages
		    The maximum number of pages that a book will render as,
		    regardless of the true number of pages.

		 min_height_percentage
		    Books with the minimum height will render as this percentage
		    width in the stack.

		 min_height
		    The minimum height in centimeters that an item will render as,
		    regardless of the true height of the item.

		 min_pages
		    The minimum number of pages that a book will render as,
		    regardless of the true number of pages.

		 page_multiple
		    A number that when multiplied by the number of pages in a book
		    gives us the total pixel height to be rendered.

		 selectors.book
		    Item selector specific to the book type.
	*/
	$.extend(true, window.StackView.defaults, {
		book: {
			max_height_percentage: 100,
			max_height: 39,
			max_pages: 540,
			min_height_percentage: 60,
			min_height: 20,
			min_pages: 200,
			page_multiple: 0.20
		},

		selectors: {
			book: '.stack-book'
		}
	});

	/*
	   #translate(number, number, number, number, number) - Private

	   Takes a value (the first argument) and two ranges of numbers. Translates
	   this value from the first range to the second range.  E.g.:

	   translate(0, 0, 10, 50, 100) returns 50.
	   translate(10, 0, 10, 50, 100) returns 100.
	   translate(5, 0, 10, 50, 100) returns 75.

	   http://stackoverflow.com/questions/1969240/mapping-a-range-of-values-to-another
	*/
	var translate = function(value, start_min, start_max, end_min, end_max) {
		var start_range = start_max - start_min,
		    end_range = end_max - end_min,
		    scale = (value - start_min) / (start_range);

		return end_min + scale * end_range;
	};

	/*
	   #get_height(StackView, object) - Private

	   Takes a StackView options object and a book object. Returns a
	   normalized book height percentage, taking into account the minimum
	   height, maximum height, height multiple, and translating them onto
	   the percentage range specified in the stack options.
	*/
	var get_height = function(options, book) {
		var height = parseInt(book.height_numeric, 10),
		    min = options.book.min_height,
		    max = options.book.max_height;

		if (isNaN(height)) {
			height = (max + min) / 2;
		}
		height = Math.min(Math.max(height, min), max);
		height = translate(
			height,
			options.book.min_height,
			options.book.max_height,
			options.book.min_height_percentage,
			options.book.max_height_percentage
		);
		return height + '%';
	};

	/*
	   #get_thickness(StackView, object) - Private

	   Takes a StackView instance and a book object. Returns a normalized
	   book thickness using the number of book pages, taking into account
	   the minimum pages, maximum pages, and pages multiple.
	*/
	var get_thickness = function(options, book) {
		var thickness = parseInt(book.pages_numeric, 10),
		    min = options.book.min_pages,
		    max = options.book.max_pages,
		    multiple = options.book.page_multiple;

		if (isNaN(thickness)) {
			thickness = min;
		}
		thickness = Math.min(Math.max(thickness, min), max) * multiple;
		return thickness + 'px';
	};

	/*
	   #normalize_link(object) - Private

	   Takes an item and returns the item's link, taking into account
	   workarounds that may come from inconsistent data structure.
	*/
	var normalize_link = function(item) {
		//workaround for link construction from LibraryCloud
		return item.title_link_friendly ?
			'../shelflife/book/' + item.title_link_friendly + '/' + item.id :
			item.link;
	};

	/*
	   #get_author(object) - Private

	   Takes an item and returns the item's author, taking the first
	   author if an array of authors is defined.
	*/
	var get_author = function(item) {
		var author = item.creator && item.creator.length ? item.creator[0] : '';

		if(/^([^,]*)/.test(author)) {
			author = author.match(/^[^,]*/);
		}

		return author;
	};

  var is_hbs = function(item) {
    if ($.isArray(item.collection)) {
      return !!$.grep(item.collection, function(c) {
        return c === 'hbs_edu';
      }).length;
    }
    return item.collection === 'hbs_edu';
  };

  var is_hollis = function(item) {
    if ($.isArray(item.collection)) {
      return !!$.grep(item.collection, function(c) {
        return c === 'hollis_catalog';
      }).length;
    }
    return item.collection === 'hollis_catalog';
  };

	/*
	   Book type definition.
	*/
	window.StackView.register_type({
		name: 'book',

		match: function(item) {
			return (item.format && item.format.match(/^book$/i)) || !item.format;
		},

		adapter: function(item, options) {
			return {
				heat: window.StackView.utils.get_heat(item.shelfrank || 0),
				book_height: get_height(options, item),
				book_thickness: get_thickness(options, item),
				link: '#' + item.id,
        id: item.id,
				title: item.title,
				author: get_author(item),
				year: item.pub_date,
        rawItem: item,
        hbs: is_hbs(item),
        hollis: is_hollis(item)
			};
		},

		template: '\
			<li class="stack-item stack-book heat<%= heat %>" style="width:<%= book_height %>; height:<%= book_thickness %>;" data-stackid="<%= id %>" data-hbs="<%= hbs %>" data-hollis="<%= hollis %>">\
				<a href="<%= link %>">\
					<span class="spine-text">\
						<span class="spine-title"><%= title %></span>\
						<span class="spine-author"><%= author %></span>\
					</span>\
					<span class="spine-year"><%= year %></span>\
					<span class="stack-pages" />\
					<span class="stack-cover" />\
				</a>\
			</li>'
	});

  /* Book Component Type */
  window.StackView.register_type({
    name: 'book_component',
    match: function(item) {
      return (item.format && item.format.match(/^book component$/i));
    },

		adapter: function(item, options) {
			return {
				heat: window.StackView.utils.get_heat(item.shelfrank || 0),
				book_height: get_height(options, item),
				book_thickness: get_thickness(options, item),
				link: '#' + item.id,
        id: item.id,
				title: item.title,
				author: get_author(item),
				year: item.pub_date,
        rawItem: item,
        hbs: is_hbs(item),
        hollis: is_hollis(item)
      };
    },

    template: '\
			<li class="stack-item stack-book book-component heat<%= heat %>" style="width:<%= book_height %>; height:<%= book_thickness %>;" data-stackid="<%= id %>" data-hbs="<%= hbs %>" data-hollis="<%= hollis %>">\
				<a href="<%= link %>">\
					<span class="spine-text">\
						<span class="spine-title"><%= title %></span>\
						<span class="spine-author"><%= author %></span>\
					</span>\
					<span class="spine-year"><%= year %></span>\
					<span class="stack-pages" />\
					<span class="stack-cover" />\
				</a>\
			</li>'
  });

  /* Working Paper Type */
  window.StackView.register_type({
    name: 'working_paper',
    match: function(item) {
      return item.format === 'Working Paper';
    },

    adapter: function(item, options) {
      return {
        heat: window.StackView.utils.get_heat(item.shelfrank || 0),
        book_height: get_height(options, item),
        book_thickness: get_thickness(options, item),
        link: '#' + item.id,
        id: item.id,
        title: item.title,
        author: get_author(item),
        year: item.pub_date_numeric,
        rawItem: item,
        hbs: is_hbs(item),
        hollis: is_hollis(item)
      };
    },

    template: '\
    <li class="stack-item stack-book hbs-type working-paper heat<%= heat %>" style="width:<%= book_height %>; height:<%= book_thickness %>;" data-stackid="<%= id %>" data-hbs="<%= hbs %>" data-hollis="<%= hollis %>">\
    <a href="<%= link %>">\
    <span class="spine-text">\
    <span class="spine-title"><%= title %></span>\
    <span class="spine-author"><%= author %></span>\
    </span>\
    <span class="spine-year"><%= year %></span>\
    <span class="stack-pages" />\
    <span class="stack-cover" />\
    </a>\
    </li>'
  });

  /* Presentation Type */
  window.StackView.register_type({
    name: 'presentation',
    match: function(item) {
      return item.format === 'Presentation';
    },

    adapter: function(item, options) {
      return {
        heat: window.StackView.utils.get_heat(item.shelfrank || 0),
        book_height: get_height(options, item),
        book_thickness: get_thickness(options, item),
        link: '#' + item.id,
        id: item.id,
        title: item.title,
        author: get_author(item),
        year: item.pub_date_numeric,
        rawItem: item,
        hbs: is_hbs(item),
        hollis: is_hollis(item)
      };
    },

    template: '\
    <li class="stack-item stack-book hbs-type presentation heat<%= heat %>" style="width:<%= book_height %>; height:<%= book_thickness %>;" data-stackid="<%= id %>" data-hbs="<%= hbs %>" data-hollis="<%= hollis %>">\
    <a href="<%= link %>">\
    <span class="spine-text">\
    <span class="spine-title"><%= title %></span>\
    <span class="spine-author"><%= author %></span>\
    </span>\
    <span class="spine-year"><%= year %></span>\
    <span class="stack-pages" />\
    <span class="stack-cover" />\
    </a>\
    </li>'
  });

  /* Published Article Type */
  window.StackView.register_type({
    name: 'published_article',
    match: function(item) {
      return item.format === 'Published Article';
    },

    adapter: function(item, options) {
      return {
        heat: window.StackView.utils.get_heat(item.shelfrank || 0),
        book_height: get_height(options, item),
        book_thickness: get_thickness(options, item),
        link: '#' + item.id,
        id: item.id,
        title: item.title,
        author: get_author(item),
        year: item.pub_date_numeric,
        rawItem: item,
        hbs: is_hbs(item),
        hollis: is_hollis(item)
      };
    },

    template: '\
    <li class="stack-item stack-book hbs-type published-article heat<%= heat %>" style="width:<%= book_height %>; height:<%= book_thickness %>;" data-stackid="<%= id %>" data-hbs="<%= hbs %>" data-hollis="<%= hollis %>">\
    <a href="<%= link %>">\
    <span class="spine-text">\
    <span class="spine-title"><%= title %></span>\
    <span class="spine-author"><%= author %></span>\
    </span>\
    <span class="spine-year"><%= year %></span>\
    <span class="stack-pages" />\
    <span class="stack-cover" />\
    </a>\
    </li>'
  });

  /* Case Material Type */
  window.StackView.register_type({
    name: 'case_material',
    match: function(item) {
      return {
        'HBS Case Material': true,
        'Non-HBS Case Material': true
      }[item.format];
    },

    adapter: function(item, options) {
      return {
        heat: window.StackView.utils.get_heat(item.shelfrank || 0),
        book_height: get_height(options, item),
        book_thickness: get_thickness(options, item),
        link: '#' + item.id,
        id: item.id,
        title: item.title,
        author: get_author(item),
        year: item.pub_date_numeric,
        rawItem: item,
        hbs: is_hbs(item),
        hollis: is_hollis(item)
      };
    },

    template: '\
    <li class="stack-item stack-book hbs-type case-material heat<%= heat %>" style="width:<%= book_height %>; height:<%= book_thickness %>;" data-stackid="<%= id %>" data-hbs="<%= hbs %>" data-hollis="<%= hollis %>">\
    <a href="<%= link %>">\
    <span class="spine-text">\
    <span class="spine-title"><%= title %></span>\
    <span class="spine-author"><%= author %></span>\
    </span>\
    <span class="spine-year"><%= year %></span>\
    <span class="stack-pages" />\
    <span class="stack-cover" />\
    </a>\
    </li>'
  });

  /* Teaching and Training Material Type */
  window.StackView.register_type({
    name: 'teaching_material',
    match: function(item) {
      return {
        'HBS Teaching and Training Material': true,
        'Non-HBS Teaching and Training Material': true
      }[item.format];
    },

    adapter: function(item, options) {
      return {
        heat: window.StackView.utils.get_heat(item.shelfrank || 0),
        book_height: get_height(options, item),
        book_thickness: get_thickness(options, item),
        link: '#' + item.id,
        id: item.id,
        title: item.title,
        author: get_author(item),
        year: item.pub_date_numeric,
        rawItem: item,
        hbs: is_hbs(item),
        hollis: is_hollis(item)
      };
    },

    template: '\
    <li class="stack-item stack-book hbs-type teaching-material heat<%= heat %>" style="width:<%= book_height %>; height:<%= book_thickness %>;" data-stackid="<%= id %>" data-hbs="<%= hbs %>" data-hollis="<%= hollis %>">\
    <a href="<%= link %>">\
    <span class="spine-text">\
    <span class="spine-title"><%= title %></span>\
    <span class="spine-author"><%= author %></span>\
    </span>\
    <span class="spine-year"><%= year %></span>\
    <span class="stack-pages" />\
    <span class="stack-cover" />\
    </a>\
    </li>'
  });

  /* Unpublished Work Type */
  window.StackView.register_type({
    name: 'unpublished',
    match: function(item) {
      return item.format === 'Unpublished Work';
    },

    adapter: function(item, options) {
      return {
        heat: window.StackView.utils.get_heat(item.shelfrank || 0),
        book_height: get_height(options, item),
        book_thickness: get_thickness(options, item),
        link: '#' + item.id,
        id: item.id,
        title: item.title,
        author: get_author(item),
        year: item.pub_date_numeric,
        rawItem: item,
        hbs: is_hbs(item),
        hollis: is_hollis(item)
      };
    },

    template: '\
    <li class="stack-item stack-book hbs-type unpublished heat<%= heat %>" style="width:<%= book_height %>; height:<%= book_thickness %>;" data-stackid="<%= id %>" data-hbs="<%= hbs %>" data-hollis="<%= hollis %>">\
    <a href="<%= link %>">\
    <span class="spine-text">\
    <span class="spine-title"><%= title %></span>\
    <span class="spine-author"><%= author %></span>\
    </span>\
    <span class="spine-year"><%= year %></span>\
    <span class="stack-pages" />\
    <span class="stack-cover" />\
    </a>\
    </li>'
  });


  /* Unidentified Type */
  window.StackView.register_type({
    name: 'unidentified',
    match: function(item) {
      return true;
    },

    adapter: function(item, options) {
      return {
        heat: window.StackView.utils.get_heat(item.shelfrank || 0),
        book_height: get_height(options, item),
        book_thickness: get_thickness(options, item),
        link: '#' + item.id,
        id: item.id,
        title: item.title,
        author: get_author(item),
        year: item.pub_date_numeric,
        rawItem: item,
        hbs: is_hbs(item),
        hollis: is_hollis(item)
      };
    },

    template: '\
    <li class="stack-item stack-book hbs-type unidentified heat<%= heat %>" style="width:<%= book_height %>; height:<%= book_thickness %>;" data-stackid="<%= id %>" data-hbs="<%= hbs %>" data-hollis="<%= hollis %>">\
    <a href="<%= link %>">\
    <span class="spine-text">\
    <span class="spine-title"><%= title %></span>\
    <span class="spine-author"><%= author %></span>\
    </span>\
    <span class="spine-year"><%= year %></span>\
    <span class="stack-pages" />\
    <span class="stack-cover" />\
    </a>\
    </li>'
  });
})(jQuery, window);
