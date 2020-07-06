class AddParentIdToTasks < ActiveRecord::Migration[4.2]
  def change
    add_column :tasks, :parent_id, :integer
  end
end
