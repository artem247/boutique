# frozen_string_literal: true

class RouteParams
  attr_reader :params

  def initialize
    @params = {}
  end

  def add(key, value)
    @params[key.to_s] = value
  end

  def get(key)
    @params[key.to_s]
  end
end
