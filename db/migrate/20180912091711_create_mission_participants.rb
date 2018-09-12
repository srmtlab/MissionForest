class CreateMissionParticipants < ActiveRecord::Migration
  def change
    create_table :mission_participants do |t|
      t.referances :mission
      t.referances :user

      t.timestamps null: false
    end
  end
end
