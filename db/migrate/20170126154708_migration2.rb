class Migration2 < ActiveRecord::Migration
  def change
    remove_column :tasks, :hierarchy, :text
    add_column :missions, :hierarchy, :text
  end
end
