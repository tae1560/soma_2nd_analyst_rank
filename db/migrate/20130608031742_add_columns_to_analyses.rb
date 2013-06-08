class AddColumnsToAnalyses < ActiveRecord::Migration
  def change
    add_column :analyses, :count_winner, :integer
    add_column :analyses, :count_loser, :integer
  end
end
