class AddDefaultLossCuts < ActiveRecord::Migration
  def up
    LossCut.create(:percent => 2)
    LossCut.create(:percent => 3)
    LossCut.create(:percent => 5)
    LossCut.create(:percent => 10)
    LossCut.create(:percent => -1)
  end

  def down
    LossCut.where(:percent => 2).delete_all
    LossCut.where(:percent => 3).delete_all
    LossCut.where(:percent => 5).delete_all
    LossCut.where(:percent => 10).delete_all
    LossCut.where(:percent => -1).delete_all
  end
end
