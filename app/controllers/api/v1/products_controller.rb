module Api
    module V1
      class ProductsController < ApplicationController
       
        def index
            @products = Product.includes(:category)
            @products = @products.where('title LIKE ?', "%#{params[:search]}%") if params[:search].present?
              
            render json: @products.as_json(include: :category)
        end

        def create
          scraper = WebScraperService.new(product_params[:url])
          product_data = scraper.scrape
  
          if product_data && product_data[:title].present?
            category = Category.find_or_create_by!(name: product_data[:category_name].presence || 'General')
  
            @product = Product.new(
              url: product_params[:url],
              title: product_data[:title],
              image: product_data[:image],
              price: product_data[:price],
              description: product_data[:description] || 'No description available',
              category: category,
              additional_info: product_data[:additional_info]
            )
  
            if @product.save
              render json: @product.as_json(include: :category), status: :created
            else
              render json: { error: @product.errors.full_messages }, status: :unprocessable_entity
            end
          else
            render json: { error: 'Failed to scrape product data. Please check the URL and try again.' }, 
                   status: :unprocessable_entity
          end
        rescue StandardError => e
          Rails.logger.error("Product creation error: #{e.message}")
          render json: { error: 'An error occurred while processing your request.' }, 
                 status: :unprocessable_entity
        end
  
        private
        def product_params
          params.require(:product).permit(:url)
        end
      end
    end
  end
  