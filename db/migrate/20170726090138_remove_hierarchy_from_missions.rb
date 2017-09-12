class RemoveHierarchyFromMissions < ActiveRecord::Migration
  def change
    remove_column :missions, :hierarchy, :string
  end
end
