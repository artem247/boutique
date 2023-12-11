# frozen_string_literal: true

class Request
  attr_reader :env, :method, :path, :params

  def initialize(env)
    @env = env
    prepare
  end

  def prepare
    @env['rack.request'] = self
    @method = @env['REQUEST_METHOD']
    @path = @env['PATH_INFO']
  end

  def headers
    @env.select { |k, _v| k.start_with?('HTTP_') }
        .transform_keys { |key| format_header_key(key) }
  end

  def body_json
    @body_json ||= parse_json_body
  end

  def prepare_env_variables(route_params)
    @env['router.params'] = populate_params(route_params)
  end

  def query_params
    Rack::Utils.parse_nested_query(env['QUERY_STRING'])
  end

  private

  def parse_json_body
    body = @env['rack.input'].read
    @env['rack.input'].rewind # Reset the body stream for potential future reads
    JSON.parse(body) if json_request?
  rescue JSON::ParserError
    nil
  end

  def json_request?
    headers['content-type'] == 'application/json'
  end

  def format_header_key(key)
    key.sub(/^HTTP_/, '').downcase.split('_').join('-')
  end

  def populate_params(route_params)
    params = RouteParams.new
    route_params.each { |key, value| params.add(key, value) }
    @params = params
  end
end
