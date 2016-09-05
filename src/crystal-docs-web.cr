require "./crystal-docs-web/oauth/github"
require "./crystal-docs-web/github/client"
require "./crystal-docs-web/*"
require "kemal"

module Crystal::Docs::Web
  error 404 do
    render "src/views/404.ecr", "src/views/layouts/layout.ecr"
  end

  get "/badge.svg" do |env|
    style = env.params.query.fetch("style", "")
    response = HTTP::Client.get("https://img.shields.io/badge/crystaldocs-ref-776791.svg?style=#{style}")
    env.response.content_type = "image/svg+xml"
    response.body
  end

  get "/" do
    github_login_link = OAuth::GitHub.authorization_link
    render "src/views/welcome.ecr", "src/views/layouts/layout.ecr"
  end

  get "/auth/github/callback" do |env|
    code = env.params.query["code"]
    state = env.params.query["state"]

    response = OAuth::GitHub.exchange_code(code, state)
    github = GitHub::Client.new(response["access_token"])
    user = User.new(github.user)

    if user.exists?
      user.update(github.user_keys)
    else
      user.save(github.user_keys)
    end

    env.session["username"] = user.name
    env.redirect "/complete"
  end

  get "/complete" do |env|
    username = env.session["username"]
    github_login_link = OAuth::GitHub.authorization_link

    render "src/views/complete.ecr", "src/views/layouts/layout.ecr"
  end
end

Kemal.config.add_handler StaticFileHandler.new("/var/www")
Kemal.run
