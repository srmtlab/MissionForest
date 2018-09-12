class DropSkil < ActiveRecord::Migration
  def change
	  drop_table :skils
  end
end
