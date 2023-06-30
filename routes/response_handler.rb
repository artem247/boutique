class ResponseHandler
  def initialize(env)
    @env = env
  end

  def finish_response_with_result(result)
    @env['rack.response'].write(result[2])
    body = @env['rack.response'].finish[2]
    @env['rack.response'].finish
  end

  def respond_with_404(path)
    [404, { 'Content-Type' => 'text/html' }, ["Oops! no route for #{path}"]]
  end

  
end