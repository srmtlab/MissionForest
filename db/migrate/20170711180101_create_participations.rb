class CreateParticipations < ActiveRecord::Migration
  def change
    create_table :participations do |t|
      t.integer :authority

      t.timestamps null: false
    end
  end
end
