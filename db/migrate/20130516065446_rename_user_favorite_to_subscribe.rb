class RenameUserFavoriteToSubscribe < ActiveRecord::Migration
  def up
    rename_table :user_favorite_stock_firms, :user_subscribe_stock_firms
  end

  def down
    rename_table :user_subscribe_stock_firms, :user_favorite_stock_firms
  end
end
