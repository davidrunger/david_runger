json.array!(@stores) do |store|
  json.extract!(store, :id, :name)
  json.items do
    json.array!(store.items) do |item|
      json.extract!(item, :id, :name, :needed)
    end
  end
end
