class MissionChannel < ApplicationCable::Channel
  def subscribed
    stream_from "mission_channel_#{params['mission_id']}_#{params['mission_group']}"
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

    ActionCable.server.broadcast("mission_channel_#{params['mission_id']}_#{params['mission_group']}", {
        status: 'init',
        tasks: get_tasks(@mission, permission),
        mission: get_mission(@mission)
    })
  end

  def send_task(permission, type, operation, data)

    ActionCable.server.broadcast("mission_channel_#{params['mission_id']}_admin", {
        status: 'work',
        type: type,
        operation: operation,
        data: data
    })

    if permission != 'own'
      ActionCable.server.broadcast("mission_channel_#{params['mission_id']}_participant", {
          status: 'work',
          type: type,
          operation: operation,
          data: data
      })
    end

    if permission != 'organize'
      ActionCable.server.broadcast("mission_channel_#{params['mission_id']}_viewer", {
          status: 'work',
          type: type,
          operation: operation,
          data: data
      })
    end
  end

  def add_task(task_data_json)
    parent_task = Task.find(task_data_json['parent_task_id'])

    permission = {
        own: 1,
        organize: 2,
        publish: 3,
        lod: 4
    }.with_indifferent_access

    if permission[task_data_json['notify']] > permission[parent_task.notify]
      stack_tasks = [parent_task]



      while true do
        task = stack_tasks.last
        parent_task = Task.find(task.sub_task_of)
        if permission[task_data_json['notify']] > permission[parent_task.notify]
          stack_tasks.push(parent_task)
        else
          break
        end
      end

      while stack_tasks.length > 0
        task = stack_tasks.pop
        task.update_attributes(
            notify: task_data_json['notify']
        )

        send_task(task_data_json['notify'], 'task', 'add', {
            id: task.id,
            name: task.title,
            description: task.description,
            deadline_at: task.deadline_at,
            created_at: task.created_at,
            status: task.status,
            notify: task.notify,
            participants: Hash[task.participants.map{ |participant| [participant.id, participant.name]}],
            parent_task_id: task.sub_task_of
        })
      end
    end

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
      task_data_json['created_at'] = task.created_at
      task_data_json['children'] = []
      task_data_json['participants'] = []

      send_task(task_data_json['notify'], 'task', 'add', task_data_json)
    end
  end

  def update_task(task_data_json)
    permission = {
        own: 1,
        organize: 2,
        publish: 3,
        lod: 4
    }.with_indifferent_access

    task = Task.find(task_data_json['id'])

    if permission[task_data_json['notify']] > permission[task.notify]
      stack_tasks = [task]

      while true
        task = stack_tasks.last
        parent_task = task.parenttask
        if permission[task_data_json['notify']] > permission[parent_task.notify]
          stack_tasks.push(parent_task)
        else
          break
        end
      end

      while stack_tasks.length > 1
        task = stack_tasks.pop
        task.update_attributes(
            notify: task_data_json['notify']
        )

        send_task(task_data_json['notify'], 'task', 'update', {
            id: task.id,
            notify: task.notify
        })
      end

      if task.update_attributes(
          title: task_data_json['name'],
          description: task_data_json['description'],
          deadline_at: task_data_json['deadline_at'],
          status: task_data_json['status'],
          notify: task_data_json['notify']
      )
        send_task(task_data_json['notify'], 'task', 'update', task_data_json)
      end


    elsif permission[task_data_json['notify']] < permission[task.notify]

      if task_data_json['notify'] == 'own'
        ActionCable.server.broadcast("mission_channel_#{params['mission_id']}_participant", {
            status: 'work',
            type: 'task',
            operation: 'delete',
            data: {
                id: task.id
            }
        })
        ActionCable.server.broadcast("mission_channel_#{params['mission_id']}_viewer", {
            status: 'work',
            type: 'task',
            operation: 'delete',
            data: {
                id: task.id
            }
        })
      elsif task_data_json['notify'] == 'organize'
        ActionCable.server.broadcast("mission_channel_#{params['mission_id']}_viewer", {
            status: 'work',
            type: 'task',
            operation: 'delete',
            data: {
                id: task.id
            }
        })
      else

      end

      stack_tasks = [task]

      while stack_tasks.length > 0 do
        target_task = stack_tasks.pop

        if target_task.subtasks.size != 0
          parent_task = task_dic[target_task.id]

          task.subtasks.each do |child|

          end
        end
      end
    else
      if task.update_attributes(
          title: task_data_json['name'],
          description: task_data_json['description'],
          deadline_at: task_data_json['deadline_at'],
          status: task_data_json['status'],
          notify: task_data_json['notify']
      )
        send_task(task_data_json['notify'], 'task', 'update', task_data_json)
      end
    end
  end

  def delete_task(task_data_json)
    task = Task.find(task_data_json['id'])
    if task.destroy
      send_task(task.notify, 'task', 'delete', task_data_json)
    end
  end

  def add_task_participant(task_data_json)
    task = Task.find(task_data_json['task_id'])
    participant = User.find(task_data_json['id'])

    if task.participants.include?(participant) == false
      task.participants.push(participant)
      if task.save
        task_data_json['name'] = participant.name
        send_task(task.notify, 'task_participant', 'add', task_data_json)
      end
    end
  end

  def delete_task_participant(task_data_json)
    task = Task.find(task_data_json['task_id'])
    task.participants.delete(task_data_json['id'])

    if task.save
      send_task(task.notify, 'task_participant', 'delete', task_data_json)
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
        send_task('publish', 'mission_participant', 'add', task_data_json)
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
        send_task('publish', 'mission_admin', 'add', task_data_json)
      end
    end
  end

  def delete_mission_participant(task_data_json)
    mission = Mission.find(params['mission_id'])

    if mission.participants.size != 1
      mission.participants.delete(task_data_json['id'])
      if mission.save
        send_task('publish', 'mission_participant', 'delete', task_data_json)
      end
    end
  end

  def delete_mission_admin(task_data_json)
    mission = Mission.find(params['mission_id'])

    if mission.admins.size != 1
      mission.admins.delete(task_data_json['id'])
      if mission.save
        send_task('publish', 'mission_admin', 'delete', task_data_json)
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
      send_task('publish', 'mission', 'update', task_data_json)
    end
  end

  def delete_mission(task_data_json)
    mission = Mission.find(params['mission_id'])
    if mission.destroy
      send_task('publish', 'mission', 'delete', task_data_json)
    end
  end


  private
  def get_tasks(mission, permission)

    task_dic = { root_task_id: mission.root_task.id }
    mission.tasks.each do |task|
      if permission.include?(task.notify)
        task_dic[task.id] = {
            name: task.title,
            description: task.description,
            deadline_at: task.deadline_at,
            created_at: task.created_at,
            status: task.status,
            notify: task.notify,
            participants: Hash[task.participants.map{ |participant| [participant.id, participant.name]}],
            children: task.subtasks.map{ |subtask| permission.include?(subtask.notify) ? subtask.id : nil }.compact
        }
      end
    end
    task_dic
  end

  def get_mission(mission)
    mission_data = {
        id: mission.id,
        name: mission.title,
        description: mission.description,
        participants: Hash[mission.participants.map{ |participant| [participant.id, participant.name]}],
        admins: Hash[mission.admins.map{ |admin| [admin.id, admin.name]}]
    }
  end
end
