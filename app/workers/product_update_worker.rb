class ProductUpdateWorker
    include Sidekiq::Worker
    sidekiq_options retry: 3
  
    def perform(product_id)
      Rails.logger.info("Starting product update for product ID #{product_id}")
  
      product = Product.find_by(id: product_id)
      unless product
        Rails.logger.error("Product not found with ID #{product_id}")
        return
      end
  
      Rails.logger.info("Scraping URL: #{product.url} for product ID #{product_id}")
      scraper = WebScraperService.new(product.url)
      product_data = scraper.scrape
  
      return unless product_data

      begin
        product.update!(
          title: product_data[:title],
          price: product_data[:price],
          description: product_data[:description],
          image: product_data[:image],
          additional_info: product_data[:additional_info]
        )
        Rails.logger.info("Successfully updated product ID #{product_id}")
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error("Failed to update product #{product_id}: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n")) 
        raise
      end
    end
  end  