class AddDirectMissionToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :direct_mission_id, :integer
  end
end
