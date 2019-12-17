class MissionAdmin < ApplicationRecord
  belongs_to :mission
  belongs_to :user
end
