class AddUserColumnToDevice < ActiveRecord::Migration
  def change
    add_column :gcm_devices, :user_id, :integer, :index => true
  end
end
