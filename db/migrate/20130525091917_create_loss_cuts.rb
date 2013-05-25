class CreateLossCuts < ActiveRecord::Migration
  def change
    create_table :loss_cuts do |t|
      t.float :percent

      t.timestamps
    end

    add_column :analyses, :loss_cut_id, :integer, :index => true
  end
end
