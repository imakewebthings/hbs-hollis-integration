class StackviewsController < ActionController::Base
  require 'open-uri'
  require 'json'

  LC_ENDPOINT = (ENV['LC_ENDPOINT'] || '') + '?filter=language:English'

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
      "filter=collection:#{CGI::escape @params[:collection]}"
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
      puts build_url(filter)
      JSON.parse open(build_url(filter), { read_timeout: 60 }).read
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
      increment_page lc_read("creator_keyword:(#{@params[:query]})")
    end

    def topic_hash
      topic = @params[:query]
      query = "topic_keyword:\"#{topic}\""
      if @params[:collection] != 'hbs_edu'
        topic_record = Topic.find_by_name(topic)
        if (topic_record)
          query += " OR lcsh:\"#{topic_record.lcsh}\""
        end
      end
      increment_page lc_read(query)
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
