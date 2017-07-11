class NcpdpEHRService

  def self.initialize
  end

  def post(body)
    http_connection.post ENV["API_URL"], body do |req|
      req.headers['Content-Type'] = 'application/xml'
    end
  end

  private

  def http_connection
    Faraday.new.tap do |conn|
      conn.basic_auth(ENV["API_KEY"], ENV["API_SECRET"])
    end
  end
end
