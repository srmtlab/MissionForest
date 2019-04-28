# coding: utf-8
class User < ApplicationRecord
  include Virtuoso
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # 認証トークンはユニークに。ただしnilは許可
  validates:authentication_token, uniqueness: true, allow_nil: true
  has_many :missions
  
  has_many :participate_missions, class_name: "Mission",
	   through: :mission_participant,
           source: :users
  has_many :mission_participant

  has_many :admin_of_missions, class_name: "Mission",
          through: :mission_admin
  has_many :mission_admin

  has_many :participate_tasks, class_name: "Task",
	   through: :task_participant,
           source: :users
  has_many :task_participant


  # 認証トークンが無い場合は作成
  def ensure_authentication_token
    self.authentication_token || generate_authentication_token
  end

  # 認証トークンの作成
  def generate_authentication_token
    loop do
      old_token = self.authentication_token
      token = SecureRandom.urlsafe_base64(24).tr('lIO0', 'sxyz')
      break token if (self.update!(authentication_token: token) rescue false) && old_token != token
    end
  end

  def delete_authentication_token
    self.update(authentication_token: nil)
  end

  

  def save(*args)
    if super(*args) then
      save2virtuoso(self)
    end
  end

  def destroy(*args)
    if deletefromvirtuoso(self) then
      super(*args)
    end
  end

  def update(*args)
    if deletefromvirtuoso(self) then
      if super(*args) then
        save2virtuoso(self)
      end
    end
  end



private
  def save2virtuoso(thisuser)
    user = User.find_by(email: thisuser.email)

    id = '<http://lod.srmt.nitech.ac.jp/resource/MissionForest/users/' + user.id.to_s + '>'
    mail = '<mailto:' + user.email + '>'
    name = '"' + user.name + '"' + '@jp'

    
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
    
    
    insertquery += 'INSERT INTO <http://mf.srmt.nitech.ac.jp/>'
    insertquery += '{'
    
    insertquery += id + ' rdf:type mf:User .'
#    insertquery += id + ' foaf:mail ' + mail + ' .'
    insertquery += id + ' foaf:name '+ name + ' .'
    
    insertquery += '}'

    
    clireturn = auth_query(insertquery)
#    puts 'clireturn'
#    puts clireturn.body

    return true
  end

  def deletefromvirtuoso(task)
    id = '<http://lod.srmt.nitech.ac.jp/resource/MissionForest/users/' + user.id.to_s + '>'

    deletequery = <<-EOS
      prefix mf-user: <http://lod.srmt.nitech.ac.jp/resource/MissionForest/users/>
      
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
