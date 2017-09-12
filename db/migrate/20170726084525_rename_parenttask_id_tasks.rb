class RenameParenttaskIdTasks < ActiveRecord::Migration
  def change
    rename_column :tasks, :parenttask_id, :sub_task_of
  end
end
