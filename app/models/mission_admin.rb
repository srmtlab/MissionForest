class MissionAdmin < ActiveRecord::Base
        belongs_to :mission
        belongs_to :admin
end
