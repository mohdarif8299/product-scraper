require 'rails_helper'

RSpec.describe Api::V1::ProductsController, type: :controller do
  let!(:category) { create(:category, name: "Electronics") }
  let!(:product) { create(:product, title: "Test Product", category: category) }

  describe "GET #index" do
    it "returns a successful HTTP status code (200)" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "returns a list of products as an array" do
      get :index
      json_response = JSON.parse(response.body)
      expect(json_response).to be_an(Array)
    end

    it "includes the correct product title in the response" do
      get :index
      json_response = JSON.parse(response.body)
      expect(json_response.first["title"]).to eq(product.title)
    end
  end

  describe "POST #create" do
    let(:valid_params) { { product: { url: "https://www.amazon.in/Apple-iPhone-14-128GB-Midnight/dp/B0BDHX8Z63" } } }

    before do
      allow_any_instance_of(ProductService).to receive(:create_product).and_return(product)
    end

    context "when valid parameters are provided" do
      it "creates a new product and returns a 201 (created) status code" do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
      end

      it "returns the created product in the response" do
        post :create, params: valid_params
        json_response = JSON.parse(response.body)
        expect(json_response["title"]).to eq(product.title)
      end
    end

    context "when invalid parameters are provided" do
      before do
        allow_any_instance_of(ProductService).to receive(:create_product).and_return(nil)
      end

      it "returns a 422 (unprocessable entity) status code" do
        post :create, params: valid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns an error message in the response" do
        post :create, params: valid_params
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq('Failed to create product. Please check the URL or try again later.')
      end
    end
  end
end