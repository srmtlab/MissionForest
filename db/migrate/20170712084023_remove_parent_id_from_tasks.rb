class RemoveParentIdFromTasks < ActiveRecord::Migration[4.2]
  def change
    remove_column :tasks, :parent_id
  end
end
