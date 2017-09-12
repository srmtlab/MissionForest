class Mission < ActiveRecord::Base
  belongs_to :user
  has_many :tasks
  has_many :participations
  accepts_nested_attributes_for :tasks

  has_one :root_task, class_name: "Task",
          foreign_key: :direct_mission_id

#  serialize :hierarchy
end
