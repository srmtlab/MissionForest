class MissionChannel < ApplicationCable::Channel
  def subscribed
    stream_from "mission_channel_#{params['mission_id']}_#{params['mission_group']}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def init()
    @mission = Mission.find(params['mission_id'])

    notifies = %w(publish lod)

    if @mission.admins.include?(current_user)
      notifies = %w(own organize publish lod)
    elsif @mission.participants.include?(current_user)
      notifies = %w(organize publish lod)
    end

    ActionCable.server.broadcast("mission_channel_#{params['mission_id']}_#{params['mission_group']}", {
        status: 'init',
        tasks: get_tasks(@mission, notifies),
        mission: get_mission(@mission)
    })
  end

  def send_task(notify, type, operation, data)

    ActionCable.server.broadcast("mission_channel_#{params['mission_id']}_admin", {
        status: 'work',
        type: type,
        operation: operation,
        data: data
    })

    if notify != 'own'
      ActionCable.server.broadcast("mission_channel_#{params['mission_id']}_participant", {
          status: 'work',
          type: type,
          operation: operation,
          data: data
      })
    end

    if notify != 'organize'
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

    if Task.notifies[task_data_json['notify']] > parent_task.notify_before_type_cast
      stack_tasks = [parent_task]

      while true do
        task = stack_tasks.last

        if Mission.find(params['mission_id']).root_task.id == task.id
          break
        end

        parent_task = Task.find(task.sub_task_of)
        if Task.notifies[task_data_json['notify']] >= parent_task.notify_before_type_cast
          stack_tasks.push(parent_task)
        else
          break
        end
      end

      while stack_tasks.length > 0 do
        task = stack_tasks.pop

        if task.notify_before_type_cast != 3 && Task.notifies[task_data_json['notify']] == 3
          task.save2virtuoso
        end

        if task.update_attributes(
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

      if task.notify_before_type_cast == 3
        task.save2virtuoso
      end

      send_task(task_data_json['notify'], 'task', 'add', task_data_json)
    end
  end

  def update_task(task_data_json)

    task = Task.find(task_data_json['id'])

    if Task.notifies[task_data_json['notify']] > task.notify_before_type_cast
      stack_tasks = [task]

      while true do
        task = stack_tasks.last

        unless task.direct_mission_id.nil?
          break
        end

        parent_task = Task.find(task.sub_task_of)

        if Task.notifies[task_data_json['notify']] >= parent_task.notify_before_type_cast
          stack_tasks.push(parent_task)
        else
          break
        end
      end

      while stack_tasks.length > 1 do
        task = stack_tasks.pop

        if task.notify_before_type_cast != 3 && Task.notifies[task_data_json['notify']] == 3
          task.save2virtuoso
        end

        if task.update_attributes(
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

      task = stack_tasks.pop
      if task.update_attributes(
          title: task_data_json['name'],
          description: task_data_json['description'],
          deadline_at: task_data_json['deadline_at'],
          status: task_data_json['status'],
          notify: task_data_json['notify']
      )
        if task.notify_before_type_cast == 3
          task.save2virtuoso
        end

        task_data_json['created_at'] = task.created_at
        task_data_json['parent_task_id'] = task.sub_task_of
        task_data_json['participants'] = Hash[task.participants.map{ |participant| [participant.id, participant.name]}]

        send_task(task_data_json['notify'], 'task', 'add', task_data_json)
      end

    elsif Task.notifies[task_data_json['notify']] < task.notify_before_type_cast

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
      end

      stack_tasks = [task]

      while stack_tasks.length > 0 do
        target_task = stack_tasks.pop

        if target_task.notify_before_type_cast == 3
          target_task.deletefromvirtuoso
        end

        if target_task.id == task.id
          if target_task.update_attributes(
              title: task_data_json['name'],
              description: task_data_json['description'],
              deadline_at: task_data_json['deadline_at'],
              status: task_data_json['status'],
              notify: task_data_json['notify']
          )
            send_task(task_data_json['notify'], 'task', 'update', task_data_json)
          end
        else
          if target_task.update_attributes(
              notify: task_data_json['notify']
          )
            send_task(task_data_json['notify'], 'task', 'update', {
                id: target_task.id,
                notify: task_data_json['notify']
            })
          end
        end
        if target_task.subtasks.size != 0
          target_task.subtasks.each do |child|
            if Task.notifies[task_data_json['notify']] <= child.notify_before_type_cast
              stack_tasks.push(child)
            end
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
        if task.notify_before_type_cast == 3
          task.update2virtuoso
        end

        send_task(task_data_json['notify'], 'task', 'update', task_data_json)
      end
    end
  end

  def delete_task(task_data_json)
    task = Task.find(task_data_json['id'])
    if task.destroy
      task.deletefromvirtuoso
      send_task(task.notify, 'task', 'delete', task_data_json)
    end
  end

  def add_task_participant(task_data_json)
    target_task = Task.find(task_data_json['task_id'])
    participant = User.find(task_data_json['id'])

    stack_tasks = [target_task]

    while true do
      task = stack_tasks.last

      if Mission.find(params['mission_id']).root_task.id == task.id
        break
      end

      parent_task = Task.find(task.sub_task_of)
      stack_tasks.push(parent_task)
    end

    while stack_tasks.length > 0 do
      task = stack_tasks.pop
      unless task.participants.include?(participant)
        task.participants.push(participant)
        if task.save
          task_data_json['task_id'] = task.id
          task_data_json['name'] = participant.name
          send_task(task.notify, 'task_participant', 'add', task_data_json)
        end
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

    unless mission.participants.include?(user)
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

  def change_hierarchy(task_data_json)
    target_task = Task.find(task_data_json['id'])
    parent_task = Task.find(task_data_json['latter_parent_task_id'])

    if target_task.notify > parent_task.notify
      stack_tasks = [parent_task]

      while true do
        task = stack_tasks.last

        if Mission.find(params['mission_id']).root_task.id == task.id
          break
        end

        parent_task = Task.find(task.sub_task_of)
        if target_task.notify >= parent_task.notify
          stack_tasks.push(parent_task)
        else
          break
        end
      end

      while stack_tasks.length > 0 do
        task = stack_tasks.pop
        if task.update_attributes(
            notify: target_task.notify
        )
          if task.notify_before_type_cast != 3 && target_task.notify_before_type_cast == 3
            task.save2virtuoso
          end

          send_task(target_task.notify, 'task', 'add', {
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
    end

    target_task.update_attributes(
      sub_task_of: task_data_json['latter_parent_task_id'],
    )

    send_task(target_task.notify, 'task', 'change_hierarchy', task_data_json)
  end

  def update_mission(task_data_json)
    mission = Mission.find(params['mission_id'])

    if mission.root_task.notify == 'lod'
      mission.update2virtuoso
    end

    if mission.update_attributes(
        title: task_data_json['name'],
        description: task_data_json['description']
    )
      send_task('publish', 'mission', 'update', task_data_json)
    end
  end

  def delete_mission(task_data_json)
    mission = Mission.find(params['mission_id'])
    mission.deletefromvirtuoso
    if mission.destroy
      send_task('publish', 'mission', 'delete', task_data_json)
    end
  end


  private
  def get_tasks(mission, notifies)

    task_dic = { root_task_id: mission.root_task.id }
    mission.tasks.each do |task|
      if notifies.include?(task.notify)
        task_dic[task.id] = {
            name: task.title,
            description: task.description,
            deadline_at: task.deadline_at,
            created_at: task.created_at,
            status: task.status,
            notify: task.notify,
            participants: Hash[task.participants.map{ |participant| [participant.id, participant.name]}],
            children: task.subtasks.map{ |subtask| notifies.include?(subtask.notify) ? subtask.id : nil }.compact
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
