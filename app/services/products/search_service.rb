module Products
  class SearchService
    def initialize(search_params)
      @sort_by = search_params[:sort_by]
      @sort_direction = search_params[:sort_direction]
      @keyword = search_params[:keyword]
      @price_from = search_params[:price_from]
      @price_to = search_params[:price_to]
      @quantity_from = search_params[:quantity_from]
      @quantity_to = search_params[:quantity_to]
      @status = search_params[:status]
    end

    def call
      Product.search(build_query)
    end

    private

    def build_query
      query = {
        query: {
          bool: {
            filter: keyword_query,
            must: []
          }
        },
        aggs: {
          quantity_distribution: {
            histogram: {
              field: 'quantity',
              interval: 10000,
              min_doc_count: 0,
              extended_bounds: {
                min: 0,
                max: @quantity_from
              }
            }
          },
          quantity_distribution_custom: {
            range: {
              field: :quantity,
              ranges: [
                {
                  from: 0,
                  to: 10000,
                  key: '10000'
                },
                {
                  from: 10000,
                  to: 30000,
                  key: '30000'
                },
                {
                  from: 30000,
                  to: 45000,
                  key: '45000'
                },
                {
                  from: 45000,
                  to: @quantity_to,
                  key: "#{@quantity_to}"
                }
              ]
            }
          }
        },
        sort: [{ @sort_by.to_sym => { order: @sort_direction.to_sym}}],
        _source: { includes: fields_selected }
      }

      query[:query][:bool][:must] << price_query if @price_from.present? || @price_to.present?
      query[:query][:bool][:must] << quantity_query if @quantity_from.present? || @quantity_to.present?
      # query[:query][:bool][:must] << status_query if @status.present?
      query
    end

    def keyword_query
      [
        {
          multi_match: {
            query: @keyword,
            fields: ['name', 'description']
          }
        }
      ]
    end

    def price_query
      {
        range: {
          price: { gte: @price_from, lte: @price_to }
        }
      }
    end

    def quantity_query
      {
        range: {
          quantity: { gte: @quantity_from, lte: @quantity_to }
        }
      }
    end

    def status_query
      {
        terms: { status: @status }
      }
    end

    def fields_selected
      %i[id name description price status quantity created_at updated_at]
    end
  end
end