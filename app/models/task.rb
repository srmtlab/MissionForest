class Task < ActiveRecord::Base
  belongs_to :user
  belongs_to :mission

  enum status: [:todo, :doing, :done]

  def children
    Task.where("parent_id = ?", self.id)
  end

  def self.localized_statuses
    ["未着手", "進行中", "完了"]
  end
end
