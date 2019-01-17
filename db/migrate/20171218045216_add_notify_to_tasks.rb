class AddNotifyToTasks < ActiveRecord::Migration[4.2]
  def change
    add_column :tasks, :notify, :integer, default: 0
  end
end
