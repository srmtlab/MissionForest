class TasksLoyalty < ApplicationLoyalty
  
  def new_task?
    user != nil
  end

  def api_delete_participant?
    user == record.user
  end
end
