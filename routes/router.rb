# frozen_string_literal: true

class Router
  include HTTPVerbs
  include RouteMatcher
  include Debug

  def initialize
    @routes = []
    @middlewares = []
    @request_handler = RequestHandler.new(self)
  end

  def match(http_method, path, &handler)
    segments = path.split('/').reject(&:empty?)
    params_keys = extract_params_keys(segments)
    path = build_path_regex(segments)

    route = Route.new(http_method, path, handler, params_keys)
    @routes << route

    debug_output("Added route: method=#{http_method}, path=#{path}, block=#{handler}, params_keys=#{params_keys}")
  end

  def use(middleware)
    @middlewares << middleware
  end

  def call(env)
    request = Request.new(env)
    response = Response.new

    if @middlewares.nil? || @middlewares.empty?
      # If there are no middlewares, directly call the final application
      @request_handler.call(env)
    else
      # If there are middlewares, wrap them around the application

      @middlewares.each do |middleware|
        response = middleware.call(request, response)
        return response.finish if response.finished?
      end

      # Call the final application
      @request_handler.call(request, response)
    end
  end

  def find_route(request)
    request_method = request.method
    request_path = request.path

    @routes.each do |route|
      if route.match?(request_method, request_path)
        params = route.params
        return [route, params]
      end
    end

    [nil, {}]
  end

  private

  def extract_params_keys(segments)
    segments.select { |seg| seg.start_with?(':') || seg.start_with?('*') }.map { |seg| seg[1..] }
  end

  def build_path_regex(segments)
    segments.map! do |seg|
      if seg.start_with?(':')
        '(\w+)'
      elsif seg.start_with?('*')
        '(.+)'
      else
        seg
      end
    end

    "/#{segments.join('/')}"
  end
end
