class Migration3 < ActiveRecord::Migration[4.2]
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.integer :task_id
      t.text :body

      t.timestamps
    end
    add_index :comments, :user_id
    add_index :comments, :task_id

    create_table :attachments do |t|
      t.integer :user_id
      t.integer :task_id
      t.string :url

      t.timestamps
    end
    add_index :attachments, :user_id
    add_index :attachments, :task_id
  end
end
