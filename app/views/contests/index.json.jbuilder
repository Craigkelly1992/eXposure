json.array!(@contests) do |contest|
  json.extract! contest, :id, :brand_id, :title, :description, :rules, :prizes, :voting, :start_date, :end_date
  json.url contest_url(contest, format: :json)
end
