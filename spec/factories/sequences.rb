FactoryBot.define do
  sequence(:item_name) do |_n|
    "#{Faker::Food.unique.ingredient}-#{SecureRandom.alphanumeric(5)}"
  end
end
