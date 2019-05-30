class MissionsLoyalty < ApplicationLoyalty


  def new?
    user != nil
  end

  def create?
    user != nil
  end

  def show?
    notify = record.root_task.notify
    notify == 'publish' or notify == 'lod' or record.admins.include?(user) or record.participants.include?(user)
  end

  # =====================================================
  #
  def show_tasks?
    # user == record.user || Participation.exists?(mission_id: record.id, user_id: user)
    true
  end

  def update_hierarchy?
    true
  end
  
  def participation_user?
    # user == record.user
    true
  end

  def edit?
    user == record.user || record.admins.include?(user)
  end

  def api_create?
    user != nil
  end

  def update?
    user == record.user || record.admins.include?(user)
  end

  def destroy?
    user == record.user || record.admins.include?(user)
  end

  def add_admin?
    user == record.user || record.admins.include?(user)
  end

  def add_admin_update?
    user == record.user || record.admins.include?(user)
  end

  def api_delete_admin?
    user == record.user || record.admins.include?(user)
  end

  def add_participant?
    user == record.user || record.admins.include?(user)
  end

  def add_participant_update?
    user == record.user || record.admins.include?(user)
  end

  def api_delete_participant?
    user == record.user || record.admins.include?(user) || record.participants.include?(user)
  end
end
