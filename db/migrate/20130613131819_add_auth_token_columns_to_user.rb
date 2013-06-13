class AddAuthTokenColumnsToUser < ActiveRecord::Migration
  def change
    ## Token authenticatable
    add_column :users, :authentication_token, :string, :index => true, :unique => true
  end
end
