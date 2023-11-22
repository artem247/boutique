# frozen_string_literal: true

require_relative 'http_constants'
require_relative 'loader'


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
    router.get('/') do |request, response|
      response.finish_response_with_result([OK, { 'content-type' => CONTENT_TYPE_HTML }, 'You are at Home!'])
    end
  end

  def self.define_greet_route(router)
    router.get('/greet/:name') do |request, response|
      name = request.params.get('name')
      message = "Hello, #{name}!"
      response.finish_response_with_result([OK, { 'content-type' => CONTENT_TYPE_HTML }, message])
    end
  end

  def self.define_user_posts_route(router)
    router.get('/users/:user_id/posts/:post_id') do |request, response|
      user_id = request.params.get('user_id')
      post_id = request.params.get('post_id')
      message = "You are viewing post #{post_id} of user #{user_id}!"
      response.finish_response_with_result([OK, { 'content-type' => CONTENT_TYPE_HTML }, message])
    end
  end

  def self.define_wildcard_route(router)
    router.get('/*') do |request, response|
      wildcard_path = request.params.get('')
      message = "Wildcard path: #{wildcard_path}"
      response.finish_response_with_result([OK, { 'content-type' => CONTENT_TYPE_HTML }, message])
    end
  end
end
