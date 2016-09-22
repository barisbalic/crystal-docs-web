module OAuth
  module GitHub
    def self.authorization_link
      query_string = HTTP::Params.build do |query|
        query.add "redirect_uri", "#{ENV["CRYSTALDOCS_BASE_URL"]}/auth/github/callback"
        query.add "client_id", ENV["GITHUB_CLIENT_ID"]
        query.add "scope", "read:public_key"
        query.add "allow_signup", "false"
      end

      gh_uri = "https://github.com/login/oauth/authorize"
      [gh_uri, query_string].join("?")
    end

    def self.exchange_code(code : String)
      params = HTTP::Params.build do |form|
        form.add "client_id", ENV["GITHUB_CLIENT_ID"]
        form.add "client_secret", ENV["GITHUB_CLIENT_SECRET"]
        form.add "code", code
      end
      response = HTTP::Client.post_form("https://github.com/login/oauth/access_token", params)
      HTTP::Params.parse(response.body)
    end
  end
end
