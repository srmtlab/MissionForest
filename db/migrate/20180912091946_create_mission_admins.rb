class CreateMissionAdmins < ActiveRecord::Migration
  def change
    create_table :mission_admins do |t|
      t.references :mission
      t.references :user

      t.timestamps null: false
    end
  end
end
