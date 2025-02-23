# app/controllers/api/v1/products_controller.rb
module Api
    module V1
      class ProductsController < ApplicationController
        before_action :set_product_service, only: :create
  
        def index
          products = fetch_products
          
          products.each(&:schedule_update)

          render json: products.as_json(include: :category)
        end
  
        def create
          product = @product_service.create_product
  
          if product
            render json: product.as_json(include: :category), status: :created
          else
            render json: { error: 'Failed to create product. Please check the URL or try again later.' }, status: :unprocessable_entity
          end
        end
  
        private
  
        def set_product_service
          @product_service = ProductService.new(product_params[:url])
        end
  
        def fetch_products
          products = Product.includes(:category)
          products = products.where('title LIKE ?', "%#{params[:search]}%") if params[:search].present?
          products
        end
  
        def product_params
          params.require(:product).permit(:url)
        end
      end
    end
  end
  