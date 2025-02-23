class Product < ApplicationRecord
  belongs_to :category

  validates :url, presence: true, uniqueness: true
  validates :title, presence: true
  validates :price, presence: true
  validates :image, presence: true

end
