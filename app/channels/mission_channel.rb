class MissionChannel < ApplicationCable::Channel
  def subscribed
    stream_from "mission_channel_#{params['mission_id']}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def init()
    @mission = Mission.find(params['mission_id'])

    permission = %w(publish, lod)

    if @mission.admins.include?(current_user) || @mission.user == current_user
      permission = %w(own, organize, publish, lod)
    elsif @mission.participants.include?(current_user) || @mission.user == current_user
      permission = %w(organize, publish, lod)
    end

    ActionCable.server.broadcast("mission_channel_#{params['mission_id']}", {
                                     'status' => 'init',
                                     'tasks' => get_tasks(@mission, permission)
    })
  end

  private
  def get_tasks(mission, permission)
    root_task = mission.root_task

    task_dic = {
        root_task.id => {
            'id' => root_task.id,
            'name' => root_task.title,
            'description' => root_task.description,
            'deadline_at' => root_task.deadline_at,
            'created_at' => root_task.created_at,
            'status' => root_task.status,
            'notify' => root_task.notify
        }
    }
    stack_tasks = [root_task]

    while stack_tasks.length > 0
      task = stack_tasks.pop

      if ! task.subtasks[0].nil?
        parent_task = task_dic[task.id]
        parent_task['children'] = []

        task.subtasks.each do |child|
          if permission.include?(child.notify)
            task_data = {
                'id' => child.id,
                'name' => child.title,
                'description' => child.description,
                'deadline_at' => child.deadline_at,
                'created_at' => child.created_at,
                'status' => child.status,
                'notify' => child.notify
            }
            parent_task['children'].push(task_data)
            task_dic[child.id] = task_data
            stack_tasks.push(child)
          end
        end
      end
    end
    task_dic[root_task.id]
  end

  def change_tasktree(data)
    ActionCable.server.broadcast("mission_channel_#{params['mission_id']}", data['tree'])
  end
end
