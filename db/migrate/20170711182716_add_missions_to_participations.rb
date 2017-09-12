class AddMissionsToParticipations < ActiveRecord::Migration
  def change
    add_reference :participations, :mission, index: true, foreign_key: true
  end
end
