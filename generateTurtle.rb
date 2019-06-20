# foreman run bundle exec rails c
# load 'generateTurtle.rb'

MF_RESOURCE = ENV["MF_RESOURCE"]
MF_ONTOLOGY = ENV["MF_ONTOLOGY"]
TASK_RESOURCE_PREF = MF_RESOURCE + 'tasks/'
USER_RESOURCE_PREF = MF_RESOURCE + 'users/'
MISSION_RESOURCE_PREF = MF_RESOURCE + 'missions/'
MF_GRAPH_URI = ENV["MF_GRAPH_URI"]

def convert_ttl(subject, predicate, object)
    subject + " " + predicate + " " + object + ". "
end

def make_ontology(query)
    "<" + MF_ONTOLOGY + query + ">"
end

ttl = <<-EOS
prefix foaf: <http://xmlns.com/foaf/0.1/>
prefix dct: <http://purl.org/dc/terms/>
prefix xsd: <http://www.w3.org/2001/XMLSchema#>
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
EOS

Mission.all.each do |mission|
    unless mission.root_task.notify == 'lod'
        next
    end

    mission_resource = '<' << MISSION_RESOURCE_PREF << mission.id.to_s << '>'
    user_resource = '<' << USER_RESOURCE_PREF << mission.user_id.to_s << '>'
    title = '"' << mission.title << '"@ja'
    created_at = '"' << mission.created_at.iso8601 << '"^^xsd:dateTime'
    updated_at = '"' << mission.updated_at.iso8601 << '"^^xsd:dateTime'


    ttl << convert_ttl(mission_resource,'rdf:type',make_ontology('Mission'))
    ttl << convert_ttl(mission_resource, 'dct:title', title)

    unless mission.description.blank?
      description = '"""' << mission.description << '"""' << '@ja'
      ttl << convert_ttl(mission_resource, 'dct:description', description)
    end

    ttl << convert_ttl(mission_resource,'dct:creator',user_resource)

    ttl << convert_ttl(mission_resource, 'dct:dateSubmitted', created_at)
    ttl << convert_ttl(mission_resource, 'dct:modified', updated_at)
end

Task.all.each do |task|
    unless task.notify == 'lod'
        next
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
      next
    end

    ttl << convert_ttl(task_resource, 'rdf:type', make_ontology('Task'))
    ttl << convert_ttl(task_resource, 'dct:title', title)

    unless task.description.blank?
      description = '"""' << task.description << '"""@ja'
      ttl << convert_ttl(task_resource, 'dct:description', description)
    end

    ttl << convert_ttl(task_resource, make_ontology('status'), status)

    unless task.deadline_at.nil?
      deadline_at = '"' << task.deadline_at.iso8601 << '"^^xsd:dateTime'
      ttl << convert_ttl(task_resource, make_ontology('deadline'), deadline_at)
    end

    unless task.sub_task_of.nil?
      parenttask_resource = '<' + TASK_RESOURCE_PREF + task.sub_task_of.to_s + '>'
      ttl << convert_ttl(task_resource, make_ontology('subTaskOf'), parenttask_resource)
    end

    ttl << convert_ttl(task_resource, 'dct:creator', user_resource)
    ttl << convert_ttl(task_resource, make_ontology('mission'), mission_resource)
    ttl << convert_ttl(task_resource, 'dct:dateSubmitted', created_at)
    ttl << convert_ttl(task_resource, 'dct:modified', updated_at)
end

User.all.each do |user|

    user_resource = '<' << USER_RESOURCE_PREF << user.id.to_s << '>'
    name = '"' << user.name << '"@ja'

    ttl << convert_ttl(user_resource, 'rdf:type', make_ontology('User'))
    ttl << convert_ttl(user_resource, 'foaf:name', name)
end

puts ttl