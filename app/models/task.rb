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
    %w(未着手 進行中 完了 取りやめ)
  end

  def self.localized_notifies
    %w(個人的構想 組織内限定 外部公開 LOD)
  end

  def save2virtuoso(task = self)
    unless LOD || task.notify == 'lod'
      return true
    end

    unless task.direct_mission_id.nil?
      task.mission.save2virtuoso
    end

    task_resource = '<' << TASK_RESOURCE_PREF << task.id.to_s << '>'
    user_resource = '<' << USER_RESOURCE_PREF << task.user_id.to_s << '>'
    mission_resource = '<' << MISSION_RESOURCE_PREF << task.mission_id.to_s << '>'
    title = '"' << task.title << '"@ja'
    created_at = '"' << task.created_at.iso8601 << '"^^xsd:dateTime'
    updated_at = '"' << task.updated_at.iso8601 << '"^^xsd:dateTime'

    case task.status
    when 'todo'
      status = '"未着手"@ja'
    when 'doing'
      status = '"進行中@ja"'
    when 'done'
      status = '"完了@ja"'
    when 'cancel'
      status = '"取りやめ"@ja'
    else
      # プログラムにエラーがあった場合の誤作動を防ぐためのコード
      return false
    end

    query = <<-EOS
      prefix dct: <http://purl.org/dc/terms/>
      prefix xsd: <http://www.w3.org/2001/XMLSchema#>
      prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    EOS

    query << 'INSERT INTO <' << LOD_GRAPH_URI << '> { '
    query << convert_ttl(task_resource, 'rdf:type', make_ontology('Task'))
    query << convert_ttl(task_resource, 'dct:title', title)

    unless task.description.blank?
      description = '"""' << task.description << '"""@ja'
      query << convert_ttl(task_resource, 'dct:description', description)
    end

    query << convert_ttl(task_resource, make_ontology('status'), status)

    unless task.deadline_at.nil?
      deadline_at = '"' << task.deadline_at.iso8601 << '"^^xsd:dateTime'
      query << convert_ttl(task_resource, make_ontology('deadline'), deadline_at)
    end

    unless task.sub_task_of.nil?
      parenttask_resource = '<' + TASK_RESOURCE_PREF + task.sub_task_of.to_s + '>'
      query << convert_ttl(task_resource, make_ontology('subTaskOf'), parenttask_resource)
    end

    query << convert_ttl(task_resource, 'dct:creator', user_resource)
    query << convert_ttl(task_resource, make_ontology('mission'), mission_resource)
    query << convert_ttl(task_resource, 'dct:dateSubmitted', created_at)
    query << convert_ttl(task_resource, 'dct:modified', updated_at)
    query << '}'

    # clireturn = auth_query(query)
  end

  def update2virtuoso(task = self)
    unless LOD || task.notify == 'lod'
      return true
    end

    task_resource = '<' << TASK_RESOURCE_PREF << task.id.to_s << '>'
    user_resource = '<' << USER_RESOURCE_PREF << task.user_id.to_s << '>'
    mission_resource = '<' << MISSION_RESOURCE_PREF << task.mission_id.to_s << '>'
    title = '"' << task.title << '"@ja'
    created_at = '"' << task.created_at.iso8601 << '"^^xsd:dateTime'
    updated_at = '"' << task.updated_at.iso8601 << '"^^xsd:dateTime'

    case task.status
    when 'todo'
      status = '"未着手"@ja'
    when 'doing'
      status = '"進行中@ja"'
    when 'done'
      status = '"完了@ja"'
    when 'cancel'
      status = '"取りやめ"@ja'
    else
      # プログラムにエラーがあった場合の誤作動を防ぐためのコード
      return false
    end

    query = <<-EOS
      prefix dct: <http://purl.org/dc/terms/>
      prefix xsd: <http://www.w3.org/2001/XMLSchema#>
      prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    EOS

    query << 'WITH <' << LOD_GRAPH_URI << '> DELETE {'
    query << task_resource << ' ?q ?o. }'
    query << 'INSERT { '
    query << convert_ttl(task_resource, 'rdf:type', make_ontology('Task'))
    query << convert_ttl(task_resource, 'dct:title', title)

    unless task.description.blank?
      description = '"""' << task.description << '"""' << '@ja'
      query << convert_ttl(task_resource, 'dct:description', description)
    end

    query << convert_ttl(task_resource, make_ontology('status'), status)

    unless task.deadline_at.nil?
      deadline_at = '"' << task.deadline_at.iso8601 << '"^^xsd:dateTime'
      query << convert_ttl(task_resource, make_ontology('deadline'), deadline_at)
    end

    unless task.sub_task_of.nil?
      parenttask_resource = '<' << TASK_RESOURCE_PREF << task.sub_task_of.to_s << '>'
      query << convert_ttl(task_resource, make_ontology('subTaskOf'), parenttask_resource)
    end

    query << convert_ttl(task_resource, 'dct:creator', user_resource)
    query << convert_ttl(task_resource, make_ontology('mission'), mission_resource)
    query << convert_ttl(task_resource, 'dct:dateSubmitted', created_at)
    query << convert_ttl(task_resource, 'dct:modified', updated_at)
    query << '}'

    # clireturn = auth_query(query)
  end

  def deletefromvirtuoso(task=self)
    unless LOD
      return true
    end

    unless task.direct_mission_id.nil?
      task.mission.deletefromvirtuoso
    end

    task_resource = '<' << TASK_RESOURCE_PREF << task.id.to_s << '>'

    query = 'WITH <' << LOD_GRAPH_URI << '> DELETE {'
    query << convert_ttl(task_resource,'?p','?o') << ' } WHERE {'
    query << convert_ttl(task_resource,'?p','?o')
    query << '}'
    # clireturn = auth_query(query)

    query = 'WITH <' << LOD_GRAPH_URI << '> DELETE {'
    query << convert_ttl('?s','?p',task_resource) << ' } WHERE {'
    query << convert_ttl('?s','?p',task_resource)
    query << '}'
    # clireturn = auth_query(query)
  end
end
