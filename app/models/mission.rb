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


  def save2virtuoso(mission=self)
    unless LOD || mission.root_task.notify == 'lod'
      return true
    end

    mission_resource = '<' << MISSION_RESOURCE_PREF << mission.id.to_s << '>'
    user_resource = '<' << USER_RESOURCE_PREF << mission.user_id.to_s << '>'
    title = '"' << mission.title << '"@ja'
    created_at = '"' << mission.created_at.iso8601 << '"^^xsd:dateTime'
    updated_at = '"' << mission.updated_at.iso8601 << '"^^xsd:dateTime'

    query = <<-EOS
      prefix foaf: <http://xmlns.com/foaf/0.1/>
      prefix dct: <http://purl.org/dc/terms/>
      prefix xsd: <http://www.w3.org/2001/XMLSchema#>
      prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    EOS

    query << 'INSERT INTO <' << LOD_GRAPH_URI << '> { '
    query << convert_ttl(mission_resource,'rdf:type',make_ontology('Mission'))
    query << convert_ttl(mission_resource, 'dct:title', title)

    unless mission.description.blank?
      description = '"""' << mission.description << '"""' << '@ja'
      query << convert_ttl(mission_resource, 'dct:description', description)
    end

    query << convert_ttl(mission_resource,'dct:creator',user_resource)

    query << convert_ttl(mission_resource, 'dct:dateSubmitted', created_at)
    query << convert_ttl(mission_resource, 'dct:modified', updated_at)
    query << '}'

    puts query

    # clireturn = auth_query(query)
  end

  def update2virtuoso(mission=self)
    unless LOD || mission.root_task.notify == 'lod'
      return true
    end

    mission_resource = '<' << MISSION_RESOURCE_PREF << mission.id.to_s << '>'
    user_resource = '<' << USER_RESOURCE_PREF << mission.user_id.to_s << '>'
    title = '"' << mission.title << '"@ja'
    created_at = '"' << mission.created_at.iso8601 << '"^^xsd:dateTime'
    updated_at = '"' << mission.updated_at.iso8601 << '"^^xsd:dateTime'

    query = <<-EOS
      prefix foaf: <http://xmlns.com/foaf/0.1/>
      prefix dct: <http://purl.org/dc/terms/>
      prefix xsd: <http://www.w3.org/2001/XMLSchema#>
      prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    EOS

    query << 'WITH <' << LOD_GRAPH_URI << '> DELETE {'
    query << mission_resource << ' ?q ?o. }'
    query << 'INSERT { '
    query << convert_ttl(mission_resource, 'dct:title', title)

    unless mission.description.blank?
      description = '"""' << mission.description << '"""' << '@ja'
      query << convert_ttl(mission_resource, 'dct:description', description)
    end

    query << convert_ttl(mission_resource,'rdf:type',make_ontology('Mission'))
    query << convert_ttl(mission_resource,'dct:creator',user_resource)

    query << convert_ttl(mission_resource, 'dct:dateSubmitted', created_at)
    query << convert_ttl(mission_resource, 'dct:modified', updated_at)
    query << '}'

    # clireturn = auth_query(query)
  end

  def deletefromvirtuoso(mission=self)
    unless LOD
      return true
    end

    mission_resource = '<' << MISSION_RESOURCE_PREF << mission.id.to_s << '>'

    query = 'WITH <' << LOD_GRAPH_URI << '> DELETE {'
    query << convert_ttl(mission_resource,'?p','?o') << ' } WHERE {'
    query << convert_ttl(mission_resource,'?p','?o')
    query << '}'
    # clireturn = auth_query(query)

    query = 'WITH <' << LOD_GRAPH_URI << '> DELETE {'
    query << convert_ttl('?s','?p',mission_resource) << ' } WHERE {'
    query << convert_ttl('?s','?p',mission_resource)
    query << '}'
    # clireturn = auth_query(deletequery)
  end
end
