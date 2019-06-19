# coding: utf-8
class User < ApplicationRecord
  include Virtuoso

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # 認証トークンはユニークに。ただしnilは許可
  validates :authentication_token, uniqueness: true, allow_nil: true
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

  def save2virtuoso(user=self)
    unless LOD
      return true
    end

    user_resource = '<' << USER_RESOURCE_PREF << user.id.to_s << '>'
    name = '"' << user.name << '"@ja'

    query = <<-EOS
      prefix dct: <http://purl.org/dc/terms/>
      prefix xsd: <http://www.w3.org/2001/XMLSchema#>
      prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      EOS

    query << 'INSERT INTO <' << LOD_GRAPH_URI << '> { '
    query << convert_ttl(user_resource, 'rdf:type', make_ontology('User'))
    query << convert_ttl(user_resource, 'foaf:name', name)
    query << '}'

    auth_query(query)
  end

  def update2virtuoso(user=self)
    unless LOD
      return true
    end

    user_resource = '<' << USER_RESOURCE_PREF << user.id.to_s << '>'
    name = '"' << user.name << '"@ja'

    query = <<-EOS
      prefix dct: <http://purl.org/dc/terms/>
      prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      prefix foaf: <http://xmlns.com/foaf/0.1/>
      EOS

    query << 'WITH <' << LOD_GRAPH_URI << '> DELETE {'
    query << user_resource << ' ?q ?o. }'
    query << 'INSERT { '
    query << convert_ttl(user_resource, 'rdf:type', make_ontology('User'))
    query << convert_ttl(user_resource, 'foaf:name', name)
    query << '}'

    auth_query(query)
  end

  # def deletefromvirtuoso(user)
  #   id = '<http://lod.srmt.nitech.ac.jp/resource/MissionForest/users/' + thisuser.id.to_s + '>'

  #   deletequery = <<-EOS
  #     prefix mf-user: <http://lod.srmt.nitech.ac.jp/resource/MissionForest/users/>
      
  #     WITH <http://mf.srmt.nitech.ac.jp/>
  #     DELETE {
  #   EOS
  #   deletequery += id + ' ?q ?o'
  #   deletequery += <<-EOS
  #     }
  #     WHERE {
  #   EOS
  #   deletequery += id + ' ?q ?o'
  #   deletequery += '}'

  #   auth_query(deletequery)
  # end
end
