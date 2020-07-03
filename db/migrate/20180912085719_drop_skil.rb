class DropSkil < ActiveRecord::Migration[4.2]
  def change
	  drop_table :skils
  end
end
