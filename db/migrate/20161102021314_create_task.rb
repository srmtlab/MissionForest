class CreateTask < ActiveRecord::Migration[4.2]
  def change
    create_table :tasks do |t|
      t.integer :user_id
      t.integer :mission_id
      t.string :title
      t.text :description

      t.timestamps
    end
    add_index :tasks, :user_id
    add_index :tasks, :mission_id
  end
end
