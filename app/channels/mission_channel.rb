class MissionChannel < ApplicationCable::Channel
  def subscribed
    stream_from "mission_channel_#{params['mission_id']}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def init(data)
    puts data
  end

  def change_tasktree(data)
    ActionCable.server.broadcast("mission_channel_#{params['mission_id']}", data['tree'])
  end
end
