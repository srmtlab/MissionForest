class CreateMission < ActiveRecord::Migration[4.2]
  def change
    create_table :missions do |t|
      t.integer :user_id
      t.string :title
      t.text :description

      t.timestamps
    end
    add_index :missions, :user_id
  end
end
