class Mission < ActiveRecord::Base
  belongs_to :user
  has_many :tasks
  accepts_nested_attributes_for :tasks

  serialize :hierarchy
end
