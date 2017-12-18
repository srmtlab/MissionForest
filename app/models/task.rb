# coding: utf-8
class Task < ActiveRecord::Base
  include Virtuoso
  
  belongs_to :user
  belongs_to :mission
  has_many :skils
  has_many :comments
  has_many :attachments

  enum status: [:todo, :doing, :done]
  enum notify: [:own, :organize, :publish, :lod]

  #def children
  #  Task.where("parent_id = ?", self.id)
  #end

  has_many :subtasks, class_name: "Task",
           foreign_key: "sub_task_of"

  belongs_to :parenttask, class_name: "Task"
  belongs_to :direct_mission, class_name: "Mission"

  def self.localized_statuses
    ["未着手", "進行中", "完了"]
  end

  def self.localized_notify
    ["個人的構想", "組織内限定", "外部公開", "LOD"]
  end

=begin
  def save
    super
    save2virtuoso(self)
    return true
  end

  def destroy
    deletefromvirtuoso(self)
    super
  end

  def update
    deletefromvirtuoso(self)
    super
    save2virtuoso(self)
  end
    
  

  private
  def save2virtuoso(task)
    id = 'mf-task:' + sprintf("%010d", task.id)
    user_id = 'mf-user:' + sprintf("%010d", task.user_id)
    title = '"' + task.title + '"' + '@jp'
    description = '"' + task.description + '"' + '@jp'
    created_at = '"' + task.created_at.strftime('%Y-%m-%dT%H:%M:%S+09:00') + '"^^xsd:tateTime'
    updated_at = '"' + task.updated_at.strftime('%Y-%m-%dT%H:%M:%S+09:00') + '"^^xsd:tateTime'
    mission_id = 'mf-mission:' +  sprintf("%010d", task.mission_id)

    case task.status
    when 'todo' then
      status = '"未着手"@jp'
    when 'doing' then
      status = '"進行中@jp"'
    when 'done'
      status = '"完了@jp"'
    end

    
    insertquery = <<-EOS
      prefix mf-user: <http://lod.srmt.nitech.ac.jp/MissionForest/users/>
      prefix mf-mission: <http://lod.srmt.nitech.ac.jp/MissionForest/missions/>
      prefix foaf: <http://xmlns.com/foaf/0.1/>
      prefix dct: <http://purl.org/dc/terms/>
      prefix mf-task: <http://lod.srmt.nitech.ac.jp/MissionForest/tasks/>
      prefix mf: <http://lod.srmt.nitech.ac.jp/MissionForest/ontology/>
      prefix xsd: <http://www.w3.org/2001/XMLSchema#>
      prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      INSERT DATA {
      GRAPH <http://localhost:8890/MissionForest/>{
      EOS

    insertquery += id + ' rdf:type mf:Task ;'
    insertquery += 'dct:creator ' + user_id + ' ;'
    insertquery += 'dct:modified '+ updated_at + ' ;'
    insertquery += 'dct:description '+ description + ' ;'
    insertquery += 'dct:dateSubmitted '+ created_at + ' ;'
    insertquery += 'mf:status '+ status + ' ;'
    insertquery += 'mf:mission '+ mission_id + ' ;'
    insertquery += 'dct:title '+ title + '.'
    insertquery += '}}'
    
    clireturn = auth_query(insertquery)
  end

  def deletefromvirtuoso(task)
    id = 'mf-task:' + sprintf("%010d", mission.id)

    deletequery = <<-EOS
      prefix mf-task: <http://lod.srmt.nitech.ac.jp/MissionForest/tasks/>

      DELETE {
             GRAPH <http://localhost:8890/MissionForest/>{
      EOS
    deletequery += id + ' ?q ?o'
    deletequery += <<-EOS
             }
      }
      WHERE {
             GRAPH <http://localhost:8890/MissionForest/>{
      EOS
    deletequery += id + ' ?q ?o'
    deletequery += '}}'
    
    clireturn = auth_query(deletequery)
  end
=end
end
