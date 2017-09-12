class AddParticipationsToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :participation, index: true, foreign_key: true
  end
end
