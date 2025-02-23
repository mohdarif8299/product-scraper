class Product < ApplicationRecord
  belongs_to :category

  validates :url, presence: true, uniqueness: true
  validates :title, presence: true
  validates :price, presence: true
  validates :image, presence: true

  scope :outdated, -> { where('updated_at < ?', 1.week.ago) }
    
  def needs_update?
    updated_at < 1.week.ago
  end

  def schedule_update
    Rails.logger.info("Calling Perform")
    ProductUpdateWorker.perform_async(id) if needs_update?
  end

end
