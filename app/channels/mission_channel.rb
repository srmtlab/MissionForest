class MissionChannel < ApplicationCable::Channel
  def subscribed
    stream_from "mission_channel_#{params['mission_id']}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def init()
    @mission = Mission.find(params['mission_id'])

    permission = %w(publish lod)

    if @mission.admins.include?(current_user)
      permission = %w(own organize publish lod)
    elsif @mission.participants.include?(current_user)
      permission = %w(organize publish lod)
    end

    ActionCable.server.broadcast("mission_channel_#{params['mission_id']}", {
        status: 'init',
        tasks: get_tasks(@mission, permission),
        mission: get_mission(@mission)
    })
  end

  def add_task(task_data_json)
    task = Task.new(
        user_id: current_user.id,
        mission_id: params['mission_id'],
        title: task_data_json['name'],
        description: task_data_json['description'],
        sub_task_of: task_data_json['parent_task_id'],
        deadline_at: task_data_json['deadline_at'],
        status: task_data_json['status'],
        notify: task_data_json['notify']
    )

    if task.save
      task_data_json['id'] = task.id
      task_data_json.delete(:parent_task_id)
      task_data_json['children'] = []

      ActionCable.server.broadcast("mission_channel_#{params['mission_id']}", {
          status: 'work',
          type: 'task',
          operation: 'add',
          data: task_data_json
      })
    end
  end

  def update_task(task_data_json)
    task = Task.find(task_data_json['id'])
    if task.update_attributes(
        title: task_data_json['name'],
        description: task_data_json['description'],
        deadline_at: task_data_json['deadline_at'],
        status: task_data_json['status'],
        notify: task_data_json['notify']
    )

      ActionCable.server.broadcast("mission_channel_#{params['mission_id']}", {
          status: 'work',
          type: 'task',
          operation: 'update',
          data: task_data_json
      })
    end
  end

  def delete_task(task_data_json)
    task = Task.find(task_data_json['id'])
    if task.destroy
      ActionCable.server.broadcast("mission_channel_#{params['mission_id']}", {
          status: 'work',
          type: 'task',
          operation: 'delete',
          data: task_data_json
      })
    end
  end

  def add_task_participant(task_data_json)
    task = Task.find(task_data_json['task_id'])
    participant = User.find(task_data_json['id'])


    if task.participants.include?(participant) == false
      task.participants.push(participant)
      if task.save
        task_data_json['name'] = participant.name
        ActionCable.server.broadcast("mission_channel_#{params['mission_id']}", {
            status: 'work',
            type: 'task_participant',
            operation: 'add',
            data: task_data_json
        })
      end
    end
  end

  def delete_task_participant(task_data_json)
    task = Task.find(task_data_json['task_id'])
    task.participants.delete(task_data_json['id'])

    if task.save
      ActionCable.server.broadcast("mission_channel_#{params['mission_id']}", {
          status: 'work',
          type: 'task_participant',
          operation: 'delete',
          data: task_data_json
      })
    end
  end

  def add_mission_participant(task_data_json)
    mission = Mission.find(params['mission_id'])
    if task_data_json.key?('id')
      user = User.find(task_data_json['id'])  
    elsif task_data_json.key?('name')
      user = User.find_by(name: task_data_json['name'])  
    end
    
    if mission.participants.include?(user) == false
      mission.participants.push(user)
      if mission.save
        if task_data_json.key?('id')
          task_data_json['name'] = user.name
        elsif task_data_json.key?('name')
          task_data_json['id'] = user.id
        end
        ActionCable.server.broadcast("mission_channel_#{params['mission_id']}", {
            status: 'work',
            type: 'mission_participant',
            operation: 'add',
            data: task_data_json
        })
      end
    end
  end

  def add_mission_admin(task_data_json)
    mission = Mission.find(params['mission_id'])
    user = User.find_by(name: task_data_json['name'])

    if mission.participants.include?(user) && mission.admins.include?(user) == false
      mission.admins.push(user)

      if mission.save
        task_data_json['id'] = user.id
        ActionCable.server.broadcast("mission_channel_#{params['mission_id']}", {
            status: 'work',
            type: 'mission_admin',
            operation: 'add',
            data: task_data_json
        })
      end
    end
  end

  def delete_mission_participant(task_data_json)
    mission = Mission.find(params['mission_id'])
    
    if mission.participants.size != 1
      mission.participants.delete(task_data_json['id'])  
      if mission.save
        ActionCable.server.broadcast("mission_channel_#{params['mission_id']}", {
            status: 'work',
            type: 'mission_participant',
            operation: 'delete',
            data: task_data_json
        })
      end  
    end
  end

  def delete_mission_admin(task_data_json)
    mission = Mission.find(params['mission_id'])

    if mission.admins.size != 1
      mission.admins.delete(task_data_json['id'])
      if mission.save
        ActionCable.server.broadcast("mission_channel_#{params['mission_id']}", {
            status: 'work',
            type: 'mission_admin',
            operation: 'delete',
            data: task_data_json
        })
      end
    end
  end

  def change_tasktree(data)
    ActionCable.server.broadcast("mission_channel_#{params['mission_id']}", data['tree'])
  end

  def update_mission(task_data_json)
    mission = Mission.find(params['mission_id'])

    if mission.update_attributes(
        title: task_data_json['name'],
        description: task_data_json['description']
    )

      ActionCable.server.broadcast("mission_channel_#{params['mission_id']}", {
          status: 'work',
          type: 'mission',
          operation: 'update',
          data: task_data_json
      })
    end
  end

  def delete_mission(task_data_json)
    mission = Mission.find(params['mission_id'])
    if mission.destroy
      ActionCable.server.broadcast("mission_channel_#{params['mission_id']}", {
          status: 'work',
          type: 'mission',
          operation: 'delete',
          data: task_data_json
      })
    end
  end

  private
  def get_tasks(mission, permission)
    root_task = mission.root_task

    task_dic = {
        root_task.id => {
            id: root_task.id,
            name: root_task.title,
            description: root_task.description,
            deadline_at: root_task.deadline_at,
            created_at: root_task.created_at,
            status: root_task.status,
            notify: root_task.notify,
            participants: root_task.participants.map{ |participant| {id: participant.id, name: participant.name}},
            children: []
        }
    }

    stack_tasks = [root_task]

    while stack_tasks.length > 0
      task = stack_tasks.pop

      if task.subtasks.size != 0
        parent_task = task_dic[task.id]

        task.subtasks.each do |child|
          if permission.include?(child.notify)

            task_data = {
                id: child.id,
                name: child.title,
                description: child.description,
                deadline_at: child.deadline_at,
                created_at: child.created_at,
                status: child.status,
                notify: child.notify,
                participants: root_task.participants.map{ |participant| {id: participant.id, name: participant.name}},
                children: []
            }

            parent_task[:children].push(task_data)
            task_dic[child.id] = task_data
            stack_tasks.push(child)
          end
        end
      end
    end
    task_dic[root_task.id]
  end

  def get_mission(mission)
    mission_data = {
        id: mission.id,
        name: mission.title,
        description: mission.description,
        participants: mission.participants.map{ |participant| {id: participant.id, name: participant.name}},
        admins: mission.admins.map{ |admin| {id: admin.id, name: admin.name}}
    }
  end
end
