# frozen_string_literal: true

class Middleware
  def initialize(app)
    @app = app
  end

  def call(env)
    # Perform actions before calling the next app.
    # This can include modifying the env, logging, etc.

    # Call the next middleware or the main app.
    status, headers, body = @app.call(env)

    # Perform actions after calling the next app.
    # This can include modifying the response, logging, etc.

    # Return the response.
    [status, headers, body]
  end
end
