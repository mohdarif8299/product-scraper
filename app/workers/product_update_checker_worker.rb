class ProductUpdateCheckerWorker
    include Sidekiq::Worker
  
    def perform
      Product.outdated.find_each do |product|
        Rails.logger.info("Scheduling update for Product ID: #{product.id}")
        ProductUpdateWorker.perform_async(product.id)
      end
    end
  end
  