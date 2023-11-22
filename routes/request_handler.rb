# frozen_string_literal: true

class RequestHandler
  include Debug

  def initialize(router)
    @router = router
  end

  def call(env)

    request = Request.new(env)
    response = Response.new

    # Prepare the environment
    handler, route_params = @router.find_route(request)
    request.prepare_env_variables(route_params)

    # Debug output
    debug_output("Incoming request: method=#{request.method}, path=#{request.path}")
    debug_output("handler = #{handler}, route_params = #{route_params}")


    if handler
      result = handler.handler.call(request, response)
      if result.is_a?(Response)
        response = result
      end
  
      if handler.path.include?('*')
        wildcard_value = request.params.get('')
        response.write("Wildcard path: #{wildcard_value}")
      end
    else
      response = Response.new(status: 404, body: ["No route matches #{request.path}"])
    end
  
    response.finish
  end
end
