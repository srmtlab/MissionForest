class AddRelationshipToTasks < ActiveRecord::Migration[4.2]
  def change
    add_reference :tasks, :parenttask, index: true
  end
end
