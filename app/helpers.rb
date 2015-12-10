helpers do
  def json(json)
    MultiJson.dump(json, pretty: true)
  end
end
