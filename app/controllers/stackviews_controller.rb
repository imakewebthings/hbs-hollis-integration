class StackviewsController < ActionController::Base
  require 'open-uri'
  require 'json'

  LC_ENDPOINT = 'http://librarycloud.harvard.edu/v1/api/item/'
  DEFAULT_PARAMS =  '?filter=collection:hollis_catalog,hbs_edu'

  def show
    @params = params
    case params[:search_type]
    when 'author'
      render json: author_hash(params)
    else
      render json: empty_hash
    end
  end

  private
    def build_url(filter)
      params = {
        limit: @params[:limit],
        start: @params[:start],
        filter: filter
      }
      [LC_ENDPOINT + DEFAULT_PARAMS, params.to_query].join '&'
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

    def author_hash(params)
      increment_page lc_read("creator:#{params[:query]}")
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
