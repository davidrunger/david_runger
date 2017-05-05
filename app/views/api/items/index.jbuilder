json.array!(@items) do |item|
  json.extract!(item, :id, :store_id, :archived, :name, :needed)
end
