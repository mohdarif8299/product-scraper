require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe ProductUpdateWorker, type: :worker do
  describe "#perform" do
    let!(:product) { FactoryBot.create(:product, url: "https://example.com/product") }
    let(:scraper) { instance_double("WebScraperService") }
    let(:scraped_data) do
      {
        title: "Updated Product Title",
        price: 199,
        description: "Updated description",
        image: "https://example.com/updated-image.jpg",
        additional_info: "Some updated info"
      }
    end

    before do
      allow(WebScraperService).to receive(:new).with(product.url).and_return(scraper)
      allow(scraper).to receive(:scrape).and_return(scraped_data)
    end

    it "updates the product with the new scraped data" do
      Sidekiq::Testing.inline! do
        ProductUpdateWorker.new.perform(product.id)
      end

      product.reload
      expect(product.title).to eq("Updated Product Title")
      expect(product.price).to eq(199)
      expect(product.description).to eq("Updated description")
      expect(product.image).to eq("https://example.com/updated-image.jpg")
      expect(product.additional_info).to eq("Some updated info")
    end
  end
end
