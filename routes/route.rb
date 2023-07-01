# frozen_string_literal: true

class Route
  attr_reader :http_method, :path, :handler, :params_keys, :params

  def initialize(http_method, path, handler, params_keys)
    @http_method = http_method
    @path = path
    @handler = handler
    @params_keys = params_keys
  end

  def match?(request_method, request_path)
    return false unless @http_method == request_method

    if @path == '/(.+)'
      @params = { '' => request_path }
      return true
    end

    match = Regexp.new("^#{@path.gsub('/', '\/')}$").match(request_path)
    return false unless match

    @params = Hash[@params_keys.zip(match.captures)]
    true
  end
end
