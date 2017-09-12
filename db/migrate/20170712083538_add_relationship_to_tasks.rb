class AddRelationshipToTasks < ActiveRecord::Migration
  def change
    add_reference :tasks, :parenttask, index: true
  end
end
