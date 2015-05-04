require 'rack'
require 'base64'

module RackHelpers
  def call_app(path, opts={})
    response_for *app.call(env_for("#{example_site}/#{path}", opts))
  end

  def example_site
    'http://example.org'
  end

  def env_for(url, opts={})
    Rack::MockRequest.env_for url, opts
  end

  def response_for(*args)
    status, headers, body = args

    Rack::Response.new [body], status, headers
  end

  def basic_auth(username, password)
    login = Base64.encode64 "#{username}:#{password}"

    {'HTTP_AUTHORIZATION' => "Basic #{login}"}
  end
end
