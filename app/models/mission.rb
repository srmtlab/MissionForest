class Mission < ActiveRecord::Base
  include Virtuoso
  
  
  belongs_to :user
  has_many :tasks
  has_many :participations
  accepts_nested_attributes_for :tasks

  has_one :root_task, class_name: "Task",
          foreign_key: :direct_mission_id


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
  end

  def root_task_update
    deletefromvirtuoso(self)
    save2virtuoso(self)
  end


  private
  def save2virtuoso(mission)
    if mission.root_task.notify != 'lod'
      return true
    end
    
    id = 'mf-mission:' + sprintf("%010d", mission.id)
    user_id = 'mf-user:' + sprintf("%010d", mission.user_id)
    title = '"' + mission.title + '"' + '@jp'
    description = '"' + mission.description + '"' + '@jp'
    created_at = '"' + mission.created_at.strftime('%Y-%m-%dT%H:%M:%S+09:00') + '"^^xsd:tateTime'
    updated_at = '"' + mission.updated_at.strftime('%Y-%m-%dT%H:%M:%S+09:00') + '"^^xsd:tateTime'

    
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
      GRAPH <http://lod.srmt.nitech.ac.jp/MissionForest/>{
      EOS

    insertquery += id + ' rdf:type mf:Mission ;'
    insertquery += 'dct:creator ' + user_id + ' ;'
    insertquery += 'dct:modified '+ updated_at + ' ;'
    insertquery += 'dct:description '+ description + ' ;'
    insertquery += 'dct:dateSubmitted '+ created_at + ' ;'
    insertquery += 'dct:title '+ title + '.'
    insertquery += '}}'
    
    clireturn = auth_query(insertquery)
    return true
  end

  def deletefromvirtuoso(mission)
    id = 'mf-mission:' + sprintf("%010d", mission.id)

    deletequery = <<-EOS
      prefix mf-mission: <http://lod.srmt.nitech.ac.jp/MissionForest/missions/>

      DELETE {
             GRAPH <http://lod.srmt.nitech.ac.jp/MissionForest/>{
      EOS
    deletequery += id + ' ?q ?o'
    deletequery += <<-EOS
             }
      }
      WHERE {
             GRAPH <http://lod.srmt.nitech.ac.jp/MissionForest/>{
      EOS
    deletequery += id + ' ?q ?o'
    deletequery += '}}'
    
    clireturn = auth_query(deletequery)
    return true
  end
end
