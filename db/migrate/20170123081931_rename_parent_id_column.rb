class RenameParentIdColumn < ActiveRecord::Migration[4.2]
  def change
    rename_column :tasks, :parend_id, :parent_id
  end
end
