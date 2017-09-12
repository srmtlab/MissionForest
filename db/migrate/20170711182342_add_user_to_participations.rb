class AddUserToParticipations < ActiveRecord::Migration
  def change
    add_reference :participations, :user, index: true, foreign_key: true
  end
end
