class RemoveParentIdFromTasks < ActiveRecord::Migration
  def change
    remove_column :tasks, :parent_id
  end
end
