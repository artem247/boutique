# frozen_string_literal: true

module HTTPVerbs
  def get(path, &block)
    verb(:get, path, &block)
  end

  def post(path, &block)
    verb(:post, path, &block)
  end

  def put(path, &block)
    verb(:put, path, &block)
  end

  def delete(path, &block)
    verb(:delete, path, &block)
  end

  private

  def verb(type, path, &block)
    match(type.to_s.upcase, path, &block)
  end
end
