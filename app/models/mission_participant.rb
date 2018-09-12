class MissionParticipant < ActiveRecord::Base
	belongs_to :missions
	belongs_to :participant, class_name: "User"
end
