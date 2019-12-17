module Virtuoso
  extend ActiveSupport::Concern
  require 'httpclient'
  require 'uri'

  def self.cast_bool?(obj)
    obj.to_s == "true"
  end

  LOD = cast_bool?(ENV["LOD"])

  if LOD
    LOD_RESOURCE = ENV["MF_RESOURCE"]
    ONTOLOGY = ENV["MF_ONTOLOGY"]
    TASK_RESOURCE_PREF = LOD_RESOURCE + 'tasks/'
    USER_RESOURCE_PREF = LOD_RESOURCE + 'users/'
    MISSION_RESOURCE_PREF = LOD_RESOURCE + 'missions/'
    LOD_GRAPH_URI = ENV["MF_GRAPH_URI"]
  end

  def auth_query(sparqlquery)
    uri = ENV["VIRTUOSO_UPDATE_ENDPOINT"]

    client = HTTPClient.new

    user = ENV["VIRTUOSO_USER"]
    password = ENV["VIRTUOSO_PASSWORD"]

    default_graph_uri = LOD_GRAPH_URI
    client.set_auth(uri, user, password)


    uri = URI(uri)
    uri.query = {
      'default-graph-uri' => default_graph_uri, 
      'query' => sparqlquery, 
      'format' => 'application/json',
      'timeout' => '0'
    }.to_param
    
    client.get(uri.to_s)
  end

  def convert_ttl(subject, predicate, object)
    subject + " " + predicate + " " + object + ". "
  end

  def make_ontology(query)
      "<" + ONTOLOGY + query + ">"
  end

end
