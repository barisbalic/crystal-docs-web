require "json"

module GitHub
  class User
    JSON.mapping(login: String, name: String)
  end

  class Key
    JSON.mapping(body: {key: "key", type: String}, title: String)
  end

  class Client
    class SomeError < ::Exception; end

    def initialize(access_token : String)
      @access_token = access_token
      @http_client = HTTP::Client.new("api.github.com", tls: true)
    end

    def user
      User.from_json( get("/user") )
    end

    def user_keys
      Array(Key).from_json( get("/user/keys") )
    end

    private def get(uri)
      response = @http_client.get(uri, default_headers)
      raise SomeError.new unless response.status_code == 200
      response.body
    end

    private def default_headers
      HTTP::Headers{"Authorization" => "token #{@access_token}"}
    end
  end
end
