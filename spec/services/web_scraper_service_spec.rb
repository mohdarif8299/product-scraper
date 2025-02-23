require 'rails_helper'

RSpec.describe WebScraperService do
  let(:url) { "https://www.amazon.in/Apple-iPhone-14-128GB-Midnight/dp/B0BDHX8Z63" }
  subject { described_class.new(url) }

  describe "#scrape" do
    context "when scraping is successful" do
      before do
        allow(subject).to receive(:extract_data).and_return({
          title: "Sample Product",
          price: 19.99,
          description: "A great product",
          category_name: "Electronics",
          image: "https://example.com/image.jpg",
          additional_info: { brand: "BrandX", rating: "4.5" }
        })
      end

      it "returns product details" do
        result = subject.scrape
        expect(result[:title]).to eq("Sample Product")
        expect(result[:price]).to eq(19.99)
      end
    end

    context "when CAPTCHA is detected" do
      before do
        allow(subject).to receive(:captcha_detected?).and_return(true)
      end

      it "returns nil" do
        expect(subject.scrape).to be_nil
      end
    end
  end
end
