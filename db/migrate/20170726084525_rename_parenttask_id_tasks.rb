class RenameParenttaskIdTasks < ActiveRecord::Migration[4.2]
  def change
    rename_column :tasks, :parenttask_id, :sub_task_of
  end
end
