# coding: utf-8
class Task < ApplicationRecord
  include Virtuoso
  
  belongs_to :user
  belongs_to :mission

  enum status: [:todo, :doing, :done, :cancel]
  enum notify: [:own, :organize, :publish, :lod]

  has_many :subtasks, class_name: "Task",
	         dependent: :destroy,
           foreign_key: "sub_task_of"

  belongs_to :parenttask, class_name: "Task", optional: true
  belongs_to :direct_mission, class_name: "Mission", optional: true

  has_many :task_participant, dependent: :destroy
  has_many :participants,
	       through: :task_participant,
         source: :user
  accepts_nested_attributes_for :task_participant

  def self.localized_statuses
    ["未着手", "進行中", "完了"]
  end

  def self.localized_notifies
    ["個人的構想", "組織内限定", "外部公開", "LOD"]
  end
  
  def save(*args)
    super(*args)
    save2virtuoso(self)
  end

  def destroy(*args)
    deletefromvirtuoso(self)
    super(*args)
  end

  def update(*args)
    deletefromvirtuoso(self)
    super(*args)
    save2virtuoso(self)
    
    if self.direct_mission_id != nil
      Mission.find(self.direct_mission_id).root_task_update()
    end
  end
  

  
  private
  def save2virtuoso(task)
    if task.notify != 'lod'
      return true
    end

    id = '<http://lod.srmt.nitech.ac.jp/resource/MissionForest/tasks/' + task.id + '>'
    user_id = '<http://lod.srmt.nitech.ac.jp/resource/MissionForest/users/' + task.user_id + '>'
    title = '"' + task.title + '"' + '@jp'
    description = '"' + task.description + '"' + '@jp'
    created_at = '"' + task.created_at.strftime('%Y-%m-%dT%H:%M:%S+09:00') + '"^^xsd:tateTime'
    updated_at = '"' + task.updated_at.strftime('%Y-%m-%dT%H:%M:%S+09:00') + '"^^xsd:tateTime'
    mission_id = '<http://lod.srmt.nitech.ac.jp/resource/MissionForest/missions/' + task.mission_id + '>'

    case task.status
    when 'todo' then
      status = '"未着手"@jp'
    when 'doing' then
      status = '"進行中@jp"'
    when 'done'
      status = '"完了@jp"'
    end

    
    insertquery = <<-EOS
      prefix mf-user: <http://lod.srmt.nitech.ac.jp/resource/MissionForest/users/>
      prefix mf-mission: <http://lod.srmt.nitech.ac.jp/resource/MissionForest/missions/>
      prefix foaf: <http://xmlns.com/foaf/0.1/>
      prefix dct: <http://purl.org/dc/terms/>
      prefix mf-task: <http://lod.srmt.nitech.ac.jp/resource/MissionForest/tasks/>
      prefix mf: <http://lod.srmt.nitech.ac.jp/resource/MissionForest/ontology#>
      prefix xsd: <http://www.w3.org/2001/XMLSchema#>
      prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

      EOS
    
    
    insertquery += 'INSERT INTO <http://mf.srmt.nitech.ac.jp>'
    insertquery += '{'
    insertquery += id + ' rdf:type mf:Task .'
    insertquery += id + ' dct:creator ' + user_id + ' .'
    insertquery += id + ' dct:modified '+ updated_at + ' .'
    insertquery += id + ' dct:description '+ description + ' .'
    insertquery += id + ' dct:dateSubmitted '+ created_at + ' .'
    insertquery += id + ' mf:status '+ status + ' .'
    insertquery += id + ' mf:mission '+ mission_id + ' .'
    insertquery += id + ' dct:title '+ title + '.'
    insertquery += '}'

    
    clireturn = auth_query(insertquery)
#    puts 'clireturn'
#    puts clireturn.body

    return true
  end

  def deletefromvirtuoso(task)
    id = '<http://lod.srmt.nitech.ac.jp/resource/MissionForest/tasks/' + task.id + '>'

    deletequery = <<-EOS
      prefix mf-task: <http://lod.srmt.nitech.ac.jp/resource/MissionForest/tasks/>
      
      WITH <http://mf.srmt.nitech.ac.jp/>
      DELETE {
      EOS
    deletequery += id + ' ?q ?o'
    deletequery += <<-EOS
      }
      WHERE {
      EOS
    deletequery += id + ' ?q ?o'
    deletequery += '}'
    
    clireturn = auth_query(deletequery)
    return true
  end
end
