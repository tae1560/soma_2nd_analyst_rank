class CreatePushMessagesOnDevices < ActiveRecord::Migration
  def change
    create_table :push_messages_on_devices do |t|
      t.datetime :push_time
      t.datetime :receive_time

      t.integer :push_message_id, :index => true
      t.integer :gcm_device_id, :index => true

      t.timestamps
    end

    add_index :push_messages_on_devices, [:push_message_id, :gcm_device_id], :name => 'by_message_and_device'
  end
end
