# frozen_string_literal: true

class Router
  include HTTPVerbs
  include RouteMatcher
  include Debug

  def initialize
    @routes = []
    @request_handler = RequestHandler.new(self)
  end

  def match(http_method, path, &handler)
    segments = path.split('/').reject(&:empty?)
    params_keys = segments.select { |seg| seg.start_with?(':') || seg.start_with?('*') }.map { |seg| seg[1..] }

    segments.map! do |seg|
      if seg.start_with?(':')
        '(\w+)'
      elsif seg.start_with?('*')
        '(.+)'
      else
        seg
      end
    end

    path = "/#{segments.join('/')}"

    route = Route.new(http_method, path, handler, params_keys)

    @routes << route

    # Debug output
    debug_output("Added route: method=#{http_method}, path=#{path}, block=#{handler}, params_keys=#{params_keys}")
  end

  def call(env)
    @request_handler.call(env)
  end

  def find_route(request_method, request_path)
    @routes.each do |route|
      if route.match?(request_method, request_path)
        params = route.params
        return [route, params]
      end
    end

    [nil, {}]
  end
end
