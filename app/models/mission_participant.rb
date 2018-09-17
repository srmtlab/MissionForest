class MissionParticipant < ActiveRecord::Base
	belongs_to :mission
	belongs_to :user
end
