# frozen_string_literal: true

class RequestHandler
  include Debug

  def initialize(router)
    @router = router
  end

  def call(env)
    preparer = RequestPreparer.new(env)
    responder = ResponseHandler.new(env)

    preparer.prepare
    method, path = preparer.extract_method_and_path

    # Debug output
    debug_output("Incoming request: method=#{method}, path=#{path}")

    handler, route_params = @router.find_route(method, path)
    debug_output("handler = #{handler}, route_params = #{route_params}")

    if handler
      env = preparer.prepare_env_variables(route_params)
      result = handler.handler.call(env)
      debug_output("handler result = #{result}")

      if handler.path.include?('*')
        # Extract the wildcard value from route_params
        wildcard_value = route_params['']
        # Modify the response body to include the wildcard path value
        result[2] = "Wildcard path: #{wildcard_value}"
      end

      responder.finish_response_with_result(result)

    else
      responder.respond_with_404(path)
    end
  end
end
