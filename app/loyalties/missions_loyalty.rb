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

  def api_create?
    user != nil
  end

  def update?
    user == record.user
  end

  def destroy?
    user == record.user
  end

  def add_admin?
    user == record.user
  end

  def add_admin_update?
    user == record.user
  end

  def api_delete_admin?
    user == record.user
  end

  def add_participant?
    user == record.user
  end

  def add_participant_update?
    user == record.user
  end

  def api_delete_participant?
    user == record.user
  end
end
