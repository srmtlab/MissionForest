class MissionAdmin < ActiveRecord::Base
        belongs_to :missions
        belongs_to :admins, class_name: "User"
end
