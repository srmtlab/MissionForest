class CreateMissionAdmins < ActiveRecord::Migration
  def change
    create_table :mission_admins do |t|
      t.referances :mission
      t.referances :user

      t.timestamps null: false
    end
  end
end
