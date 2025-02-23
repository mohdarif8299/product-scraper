require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe ProductUpdateCheckerWorker, type: :worker do
  describe "#perform" do
    it "queues a ProductUpdateWorker for each outdated product" do
      outdated_product1 = FactoryBot.create(:product, updated_at: 1.week.ago)

      allow(Product).to receive(:outdated).and_return(Product.where(id: outdated_product1.id))

      allow(ProductUpdateWorker).to receive(:perform_async)

      Sidekiq::Testing.inline! do
        ProductUpdateCheckerWorker.new.perform
      end

      expect(ProductUpdateWorker).to have_received(:perform_async).with(outdated_product1.id)
    end
  end
end
