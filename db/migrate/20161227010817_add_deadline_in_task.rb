class AddDeadlineInTask < ActiveRecord::Migration
  def change
    add_column :tasks, :deadline_at, :datetime
  end
end
