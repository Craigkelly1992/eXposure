json.array!(@posts) do |post|
  json.extract! post, :id, :uploader_id, :contest_id, :text
  json.url post_url(post, format: :json)
end
