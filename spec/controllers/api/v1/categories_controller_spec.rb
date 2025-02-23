# spec/controllers/api/v1/categories_controller_spec.rb

require 'rails_helper'

RSpec.describe Api::V1::CategoriesController, type: :controller do
  describe "GET #index" do
    it "returns a list of categories" do
      category1 = FactoryBot.create(:category, name: "Electronics")
      category2 = FactoryBot.create(:category, name: "Clothing")

      get :index

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(2)

      expect(JSON.parse(response.body).first["name"]).to eq("Electronics")
      expect(JSON.parse(response.body).last["name"]).to eq("Clothing")
    end
  end
end
