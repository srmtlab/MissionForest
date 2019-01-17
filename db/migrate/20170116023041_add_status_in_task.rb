class AddStatusInTask < ActiveRecord::Migration[4.2]
  def change
    add_column :tasks, :status, :integer, default: 0
  end
end
