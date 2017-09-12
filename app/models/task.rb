# coding: utf-8
class Task < ActiveRecord::Base
  belongs_to :user
  belongs_to :mission
  has_many :skils
  has_many :comments
  has_many :attachments

  enum status: [:todo, :doing, :done]

  #def children
  #  Task.where("parent_id = ?", self.id)
  #end

  has_many :subtasks, class_name: "Task",
           foreign_key: "sub_task_of"

  belongs_to :parenttask, class_name: "Task"
  belongs_to :direct_mission, class_name: "Mission"

  def self.localized_statuses
    ["未着手", "進行中", "完了"]
  end
end
