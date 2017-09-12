class RemoveParticipationIdFromMissions < ActiveRecord::Migration
  def change
    remove_foreign_key :missions, :participations
    remove_reference :missions, :participation, index: true
  end
end
