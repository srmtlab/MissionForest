class AddNotifyToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :notify, :integer, default: 0
  end
end
