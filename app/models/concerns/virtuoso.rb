module Virtuoso
  extend ActiveSupport::Concern
  require 'httpclient'
  def auth_query(sparqlquery)
    uri = ENV["VIRTUOSO_UPDATE_ENDPOINT"]

    client = HTTPClient.new

    user = ENV["VIRTUOSO_USER"]
    password = ENV["VIRTUOSO_PASSWORD"]

    default_graph_uri = ENV["LOD_GRAPH_URI"]
    client.set_auth(uri, user, password)
    
    query = {'default-graph-uri' => default_graph_uri, 'query' => sparqlquery, 'format' => 'application/sparql-results+json'}
    client.get(uri, query)
  end
end
