# app/services/product_service.rb
class ProductService
    def initialize(url)
      @url = url
      @scraper = WebScraperService.new(url)
    end
  
    def create_product
      product_data = scrape_product_data
      return nil unless product_data
  
      category = find_or_create_category(product_data)
      product = build_product(product_data, category)
  
      if product.save
        log_info("Successfully created product: #{product.id}")
        product
      else
        log_error("Failed to save product: #{product.errors.full_messages.join(', ')}")
        nil
      end
    rescue StandardError => e
      log_error("Error creating product: #{e.message}")
      nil
    end
  
    private
  
    def scrape_product_data
      product_data = @scraper.scrape
      return nil unless product_data && product_data[:title].present?
  
      product_data
    rescue StandardError => e
      log_error("Error scraping product data: #{e.message}")
      nil
    end
  
    def find_or_create_category(product_data)
      category_name = product_data[:category_name].presence || 'General'
      Category.find_or_create_by!(name: category_name)
    rescue ActiveRecord::RecordInvalid => e
      log_error("Error creating category: #{e.message}")
      raise
    end
  
    def build_product(product_data, category)
      Product.new(
        url: @url,
        title: product_data[:title],
        image: product_data[:image],
        price: product_data[:price],
        description: product_data[:description] || 'No description available',
        category: category,
        additional_info: product_data[:additional_info]
      )
    end
  
    def log_info(message)
      Rails.logger.info(message)
    end
  
    def log_error(message)
      Rails.logger.error(message)
    end
  end
  