class CreateTaskParticipants < ActiveRecord::Migration[4.2]
  def change
    create_table :task_participants do |t|
      t.references :task, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
