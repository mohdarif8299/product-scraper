FactoryBot.define do
    factory :product do
      title { "Test Product" }
      url { "https://www.amazon.in/Apple-iPhone-14-128GB-Midnight/dp/B0BDHX8Z63" }
      price { 19.99 }
      description { "A great product" }
      image { "https://example.com/image.jpg" }
      category
    end
  end
  