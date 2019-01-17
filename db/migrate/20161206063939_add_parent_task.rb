class AddParentTask < ActiveRecord::Migration[4.2]
  def change
    add_column :tasks, :parend_id, :integer
  end
end
