class AddParentTask < ActiveRecord::Migration
  def change
    add_column :tasks, :parend_id, :integer
  end
end
