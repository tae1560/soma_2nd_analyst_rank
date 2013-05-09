class UserFavoriteStockFirm < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user
  belongs_to :stock_firm
end
