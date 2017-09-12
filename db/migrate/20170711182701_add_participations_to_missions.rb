class AddParticipationsToMissions < ActiveRecord::Migration
  def change
    add_reference :missions, :participation, index: true, foreign_key: true
  end
end
