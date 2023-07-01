# frozen_string_literal: true

class RequestPreparer
  def initialize(env)
    @env = env
  end

  def prepare
    @env['rack.request'] = Rack::Request.new(@env)
    @env['rack.response'] = Rack::Response.new
    @env
  end

  def extract_method_and_path
    [@env['REQUEST_METHOD'], @env['PATH_INFO']]
  end

  def prepare_env_variables(route_params)
    @env['router.params'] = populate_params(route_params)
    @env
  end

  private

  def populate_params(route_params)
    params = RouteParams.new
    route_params.each { |key, value| params.add(key, value) }
    params
  end
end
