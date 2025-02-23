class AddAdditionalInfoToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :additional_info, :text
  end
end
