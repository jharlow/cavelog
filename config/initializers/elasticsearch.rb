Elasticsearch::Model.client = Elasticsearch::Client.new(
  url: "http://#{ENV["ELASTICSEARCH_HOST"]}:#{ENV["ELASTICSEARCH_PORT"]}"
)
