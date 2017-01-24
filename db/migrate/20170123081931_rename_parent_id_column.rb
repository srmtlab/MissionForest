class RenameParentIdColumn < ActiveRecord::Migration
  def change
    rename_column :tasks, :parend_id, :parent_id
  end
end
