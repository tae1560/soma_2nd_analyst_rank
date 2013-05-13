class CreatePushMessages < ActiveRecord::Migration
  def change
    create_table :push_messages do |t|
      t.string :title
      t.string :message

      t.timestamps
    end
  end
end
