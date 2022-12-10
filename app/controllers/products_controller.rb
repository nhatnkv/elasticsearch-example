class ProductsController < ApplicationController
  def index
    Products::SearchService.new(index_params).call
  end

  def index_params
    params.permit(:keyword, :sort_by, :sort_direction, :price_from, :price_to, :quantity_from, :quantity_to)
  end
end
