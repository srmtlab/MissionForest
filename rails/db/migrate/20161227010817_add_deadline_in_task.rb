class AddDeadlineInTask < ActiveRecord::Migration[4.2]
  def change
    add_column :tasks, :deadline_at, :datetime
  end
end
