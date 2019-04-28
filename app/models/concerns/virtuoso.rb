module Virtuoso
  extend ActiveSupport::Concern
  require 'httpclient'
  def auth_query(sparqlquery)
=begin
    uri = 'http://localhost:8890/sparql-auth'
    client = HTTPClient.new
    user = 'dba'
    # password = 'dba'
    password = 'srmt1ab'
    default_graph_uri = 'http://mf.srmt.nitech.ac.jp'
    client.set_auth('http://localhost:8890/', user, password)
    
    query = {'default-graph-uri' => default_graph_uri, 'query' => sparqlquery, 'format' => 'application/sparql-results+json'}
    clireturn = client.get(uri, query)
=end
    clireturn = 'no virtuoso'

    return clireturn
  end
end
