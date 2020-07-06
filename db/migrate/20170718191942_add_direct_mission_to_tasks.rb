class AddDirectMissionToTasks < ActiveRecord::Migration[4.2]
  def change
    add_column :tasks, :direct_mission_id, :integer
  end
end
