class CreateUserFavoriteStockFirms < ActiveRecord::Migration
  def change
    create_table :user_favorite_stock_firms do |t|
      t.integer :user_id, :index => true
      t.integer :stock_firm_id, :index => true

      t.timestamps
    end
  end
end
