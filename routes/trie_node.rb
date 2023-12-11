# frozen_string_literal: true

class TrieNode
  attr_accessor :children, :handler, :http_method, :params_keys

  def initialize
    @children = {}
    @handler = nil
    @http_method = nil
    @params_keys = nil
  end
end
