class AddForeignKeyOnPushMessage < ActiveRecord::Migration
  def change
    add_foreign_key(:gcm_notifications, :gcm_devices, dependent: :delete, column: :device_id)
    add_foreign_key(:push_messages_on_devices, :push_messages, dependent: :delete)
    add_foreign_key(:push_messages_on_devices, :gcm_devices, dependent: :delete)
  end
end
