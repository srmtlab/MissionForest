class MissionsLoyalty < ApplicationLoyalty

  def show?
    # user == record.user || Participation.exists?(mission_id: record.id, user_id: user)
    true
  end
  
  def show_tasks?
    # user == record.user || Participation.exists?(mission_id: record.id, user_id: user)
    true
  end
  
  def participation_user?
    # user == record.user
    true
  end

  def new?
    user != nil
  end
  
  def edit?
    user == record.user
  end

  def create?
    user != nil
  end

  def update?
    user == record.user
  end

  def destroy?
    user == record.user
  end
end
