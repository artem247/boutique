# frozen_string_literal: true
require 'json'
require 'benchmark'

class Response
  attr_accessor :status, :body
  attr_reader  :headers

  def initialize(status: 200, headers: {}, body: [])
    @status = status
    @headers = headers
    @body = body
  end

  def finish

    response_time = Benchmark.realtime do
      unless @body.is_a?(Array) && @body.all? { |element| element.is_a?(String) }
      @body = [@body]
      end

      content_length = calculate_content_length
      set_header('content-length', content_length.to_s)
    end

    

    # Calculate and set Content-Length
    content_length = calculate_content_length

    log_performance_metrics(response_time, content_length)
    
    puts "Debug: Response Body Type = #{body.class}"
    puts "Debug: Response Body Value = #{body.inspect}"
    
    [@status, @headers, @body]
  end

  # Corresponds to finish_response_with_result in ResponseHandler
  def finish_response_with_result(result)
    @status = result[0]
    @headers = result[1]
    @body = result[2]
  end

  # Corresponds to respond_with_404 in ResponseHandler
  def respond_with_404(path)
    @status = 404
    @headers = { 'content-type' => 'text/html' }
    @body = ["Oops! no route for #{path}"]
  end

  def finished?
    !@status.nil? && !@headers.nil? && !@body.nil?
  end

  # Additional methods to manipulate the response
  def set_header(name, value)
    @headers[name] = value
  end

  def set_headers(new_headers)
    @headers.merge!(new_headers)
  end

  def json(data, status: 200)
    self.status = status
    set_headers({'content-type' => 'application/json'})
    self.body = data.to_json
  end

  def html(content, status: 200)
    self.status = status
    set_headers({'content-type' => 'text/html'})
    self.body = content
  end

  def write(data)
    puts "Debug: @body Type Before Write = #{@body.class}"
    puts "Debug: @body Value Before Write = #{@body.inspect}"
      # If @body is an array, join its elements; otherwise, use @body as is.
      body_str = @body.is_a?(Array) ? @body.join : @body
    
      # Append new data to the body string.
      @body = body_str + data.to_s
    puts "Debug: @body Type After Write = #{@body.class}"
    puts "Debug: @body Value After Write = #{@body.inspect}"

  end


  private

  def calculate_content_length
    if @body.is_a?(Array)
      @body.sum { |element| element.to_s.bytesize }
    else
      @body.to_s.bytesize
    end
  end

  def log_performance_metrics(response_time, content_length)
    puts "Performance Metrics: Response Time = #{response_time.round(4)} seconds, Content Length = #{content_length} bytes"
  end


end
