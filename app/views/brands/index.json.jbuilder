json.array!(@brands) do |brand|
  json.extract! brand, :id, :agency_id, :name, :facebook, :twitter, :instagram, :slogan, :website, :description
  json.url brand_url(brand, format: :json)
end
