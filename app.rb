# frozen_string_literal: true

require_relative 'http_constants'
require_relative 'routes/request_preparer'
require_relative 'routes/response_handler'
require_relative 'routes/route'
require_relative 'routes/route_params'
require_relative 'routes/route_matcher'
require_relative 'routes/debug'
require_relative 'routes/http_verbs'
require_relative 'routes/request_handler'
require_relative 'routes/router'

class App
  include HttpConstants

  def self.router
    @router ||= begin
      router = Router.new

      define_home_route(router)
      define_greet_route(router)
      define_user_posts_route(router)
      define_wildcard_route(router)
    
      router
    end
  end

  def self.define_home_route(router)
    router.get('/') do |_env|
      [OK, { 'Content-Type' => CONTENT_TYPE_HTML }, 'You are at Home!']
    end
  end

  def self.define_greet_route(router)
    router.get('/greet/:name') do |env|
      name = env['router.params'].get('name')
      message = "Hello, #{name}!"
      [OK, { 'Content-Type' => CONTENT_TYPE_HTML }, message]
    end
  end

  def self.define_user_posts_route(router)
    router.get('/users/:user_id/posts/:post_id') do |env|
      user_id = env['router.params'].get('user_id')
      post_id = env['router.params'].get('post_id')
      message = "You are viewing post #{post_id} of user #{user_id}!"
      [OK, { 'Content-Type' => CONTENT_TYPE_HTML }, message]
    end
  end

  def self.define_wildcard_route(router)
    router.get('/*') do |env|
      wildcard_path = env['router.params'].get('')
      message = "Wildcard path: #{wildcard_path}"
      [OK, { 'Content-Type' => CONTENT_TYPE_HTML }, message]
    end
  end

end
