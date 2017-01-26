class Migration < ActiveRecord::Migration
  def change
    add_column :tasks, :hierarchy, :text
    remove_column :tasks, :parent_id, :integer

    create_table :skils do |t|
      t.integer :user_id
      t.integer :task_id
      t.string :name

      t.timestamps
    end
    add_index :skils, :user_id
    add_index :skils, :task_id
  end
end
