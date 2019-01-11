class Mission < ApplicationRecord
  include Virtuoso
  
  
  belongs_to :user
  has_many :tasks, :dependent => :destroy
  accepts_nested_attributes_for :tasks

  has_one :root_task, class_name: "Task",
          foreign_key: :direct_mission_id

  has_many :mission_participant
  has_many :participants,
	       through: :mission_participant,
           source: :user
  accepts_nested_attributes_for :mission_participant

  has_many :mission_admin
  has_many :admins,
           through: :mission_admin,
           source: :user
  accepts_nested_attributes_for :mission_admin
  
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
    if mission.root_task == nil
      return true
    end
    if mission.root_task.notify != 'lod'
      return true
    end


    id = '<http://lod.srmt.nitech.ac.jp/resource/MissionForest/missions/' + mission.id.to_s + '>'
    user_id = '<http://lod.srmt.nitech.ac.jp/resource/MissionForest/users/' + mission.user_id.to_s + '>'
    title = '"' + mission.title + '"' + '@jp'
    description = '"' + mission.description + '"' + '@jp'
    created_at = '"' + mission.created_at.strftime('%Y-%m-%dT%H:%M:%S+09:00') + '"^^xsd:tateTime'
    updated_at = '"' + mission.updated_at.strftime('%Y-%m-%dT%H:%M:%S+09:00') + '"^^xsd:tateTime'

    
    insertquery = <<-EOS
      prefix mf-user: <http://lod.srmt.nitech.ac.jp/resource/MissionForest/users/>
      prefix mf-mission: <http://lod.srmt.nitech.ac.jp/resource/MissionForest/missions/>
      prefix foaf: <http://xmlns.com/foaf/0.1/>
      prefix dct: <http://purl.org/dc/terms/>
      prefix mf-task: <http://lod.srmt.nitech.ac.jp/resource/MissionForest/tasks/>
      prefix mf: <http://lod.srmt.nitech.ac.jp/resource/MissionForest/ontology#>
      prefix xsd: <http://www.w3.org/2001/XMLSchema#>
      prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      
      INSERT INTO <http://mf.srmt.nitech.ac.jp/>
      {
      EOS

    insertquery += id + ' rdf:type mf:Mission .'
    insertquery += id + ' dct:creator ' + user_id + ' .'
    insertquery += id + ' dct:modified '+ updated_at + ' .'
    insertquery += id + ' dct:description '+ description + ' .'
    insertquery += id + ' dct:dateSubmitted '+ created_at + ' .'
    insertquery += id + ' dct:title '+ title + ' .'
    insertquery += '}'
    
    clireturn = auth_query(insertquery)
    return true
  end

  def deletefromvirtuoso(mission)
    id = '<http://lod.srmt.nitech.ac.jp/resource/MissionForest/missions/' + mission.id.to_s + '>'

    deletequery = <<-EOS
      prefix mf-mission: <http://lod.srmt.nitech.ac.jp/resource/MissionForest/missions/>

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
