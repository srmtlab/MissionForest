# このスクリプトはミッションにユーザーが参加しているかを精査し，含めるものです
# 
# export RAILS_ENV=development ( あるいは production )
# export DB_HOST=mysql
# export DB_USER=root
# export DB_PASS=root
# rails c 
# load 'fix_participant_admin.rb' 

Mission.all.order(created_at: :desc).each do |mission|
    user = mission.user

    if mission.participants.include?(user) == false
        mission.participants.push(user)    
    end

    if mission.admins.include?(user) == false
        mission.admins.push(user)
    end

    mission.save
end