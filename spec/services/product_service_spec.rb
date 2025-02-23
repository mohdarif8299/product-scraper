require 'rails_helper'

RSpec.describe ProductService do
  let(:url) { "https://www.amazon.in/Apple-iPhone-14-128GB-Midnight/dp/B0BDHX8Z63" }
  let(:scraper) { double("WebScraperService") }
  let(:category) { create(:category, name: "Electronics") }
  let(:product_data) do
    {
      title: "Sample Product",
      image: "https://www.amazon.in/Apple-iPhone-14-128GB-Midnight.jpg",
      price: 19.99,
      description: "A great product",
      category_name: "Electronics",
      additional_info: { brand: "BrandX", rating: "4.5" }
    }
  end

  subject { described_class.new(url) }

  before do
    allow(WebScraperService).to receive(:new).and_return(scraper)
    allow(scraper).to receive(:scrape).and_return(product_data)
  end

  describe "#create_product" do
    context "when product data is valid" do
      it "creates a new product" do
        expect { subject.create_product }.to change { Product.count }.by(1)
      end

      it "returns the created product" do
        product = subject.create_product
        expect(product.title).to eq("Sample Product")
      end
    end

    context "when scraping fails" do
      before do
        allow(scraper).to receive(:scrape).and_return(nil)
      end

      it "returns nil" do
        expect(subject.create_product).to be_nil
      end
    end
  end
end
