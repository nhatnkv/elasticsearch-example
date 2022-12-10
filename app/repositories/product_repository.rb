class ProductRepository
  include Elasticsearch::Persistence::Repository
  include Elasticsearch::Persistence::Repository::DSL

  index_name :products
  klass Product

  settings index: { number_of_shards: 3 } do
    mappings dynamic: 'false' do
      indexes :id, { type: :integer }
      indexes :name, { type: :text }
      indexes :price, { type: :float }
      indexes :status, { type: :keyword }
      indexes :quantity, { type: :integer }
      indexes :description, { type: :text }
      indexes :created_at, { type: :date }
      indexes :updated_at, { type: :date }
    end
  end
end