class RemoveHierarchyFromMissions < ActiveRecord::Migration[4.2]
  def change
    remove_column :missions, :hierarchy, :string
  end
end
