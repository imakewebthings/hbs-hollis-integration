class StackviewsController < ActionController::Base
  require 'open-uri'
  require 'json'

  LC_ENDPOINT = ENV['LC_ENDPOINT'] + '?filter=language:English'

  def show
    @params = params
    case params[:search_type]
    when 'author'
      render json: author_hash
    when 'topic'
      render json: topic_hash
    else
      render json: empty_hash
    end
  end

  private
    def collection_filter
      "filter=collection:#{@params[:collection]}"
    end

    def build_url(filter)
      params = {
        limit: @params[:limit],
        start: @params[:start],
        sort: @params[:sort],
        filter: filter
      }
      [LC_ENDPOINT, params.to_query, collection_filter].join '&'
    end

    def lc_read(filter)
      JSON.parse open(build_url(filter)).read
    end

    def increment_page(json)
      if @params[:start].to_i + @params[:limit].to_i > json['num_found'].to_i
        json['start'] = -1
      else
        json['start'] = json['start'].to_i + @params[:limit].to_i
      end
      json
    end

    def author_hash
      increment_page lc_read("creator_keyword:#{@params[:query]}")
    end

    def topic_hash
      field = @params[:collection] == 'hbs_edu' ? 'note_keyword' : 'lcsh'
      value = @params[:query]
      if field == 'lcsh'
        value = Topic.find_by_name(value).lcsh
      end
      increment_page lc_read("#{field}:#{value}")
    end

    def empty_hash
      {
        start: -1,
        limit: 0,
        num_found: 0,
        docs: []
      }
    end
end
