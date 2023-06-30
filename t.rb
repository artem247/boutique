# frozen_string_literal: true

require_relative 'routes/route'
require_relative 'routes/route_params'
require_relative 'routes/route_matcher'
require_relative 'routes/debug'
require_relative 'routes/http_verbs'
require_relative 'routes/request_handler'
require_relative 'routes/router'

class App
  def self.router
    @router ||= begin
      router = Router.new

      define_home_route(router)
      define_greet_route(router)
      define_user_posts_route(router)

      router
    end
  end

  def self.define_home_route(router)
    router.get('/') do |_env|
      [200, { 'Content-Type' => 'text/html' }, 'You are at Home!']
    end
  end

  def self.define_greet_route(router)
    router.get('/greet/:name') do |env|
      name = env['router.params'].get('name')
      message = "Hello, #{name}!"
      [200, { 'Content-Type' => 'text/html' }, message]
    end
  end

  def self.define_user_posts_route(router)
    router.get('/users/:user_id/posts/:post_id') do |env|
      user_id = env['router.params'].get('user_id')
      post_id = env['router.params'].get('post_id')
      message = "You are viewing post #{post_id} of user #{user_id}!"
      [200, { 'Content-Type' => 'text/html' }, message]
    end
  end
end


require 'find'

def read_files_from_folder
  buffer = []
  Find.find(Dir.pwd) do |path|
    if FileTest.file?(path) && File.extname(path) == '.rb'
      File.open(path, 'r') do |f|
        buffer << f.read
      end
    end
  end
  buffer.join("\n\n")
end

def write_to_output(buffer, output_file)
  File.open(output_file, 'w') do |f|
    f.write(buffer)
  end
end

def main
  puts 'Enter the output file name: '
  output_file = gets.chomp
  buffer = read_files_from_folder
  write_to_output(buffer, output_file)
end

main if __FILE__ == $0


# frozen_string_literal: true

module Debug
  def debug_output(message)
    puts "Debug: #{message}"
  end
end


# frozen_string_literal: true

module HTTPVerbs
  def get(path, &block)
    match('GET', path, &block)
  end

  def post(path, &block)
    match('POST', path, &block)
  end

  def put(path, &block)
    match('PUT', path, &block)
  end

  def delete(path, &block)
    match('DELETE', path, &block)
  end
end


# frozen_string_literal: true

class RequestHandler
  include Debug

  def initialize(router)
    @router = router
  end

  def call(env)
    prepare_request_and_response(env)
    method, path = extract_method_and_path(env)

    # Debug output
    debug_output("Incoming request: method=#{method}, path=#{path}")

    handler, route_params = @router.find_route(method, path)
    debug_output("handler = #{handler}, route_params = #{route_params}")

    if handler
      populate_params(route_params)
      prepare_env_variables(env, route_params)

      result = handle_request(env, handler)
      debug_output("handler result = #{result}")

      finish_response_with_result(env, result)
    else
      respond_with_404(path)
    end
  end

  private

  def prepare_request_and_response(env)
    env['rack.request'] = Rack::Request.new(env)
    env['rack.response'] = Rack::Response.new
  end

  def extract_method_and_path(env)
    [env['REQUEST_METHOD'], env['PATH_INFO']]
  end

  def debug_output(message)
    puts "Debug: #{message}"
  end

  def populate_params(route_params)
    params = RouteParams.new
    route_params.each { |key, value| params.add(key, value) }
    params
  end

  def prepare_env_variables(env, route_params)
    env['router.params'] = populate_params(route_params)
    debug_output("env['router.params'] = #{env['router.params'].params}")
  end

  def handle_request(env, route)
    route.handler.call(env)
  end

  def finish_response_with_result(env, result)
    env['rack.response'].write(result[2])
    body = env['rack.response'].finish[2]
    debug_output("Response Body = #{body.inspect}")
    env['rack.response'].finish
  end

  def respond_with_404(path)
    [404, { 'Content-Type' => 'text/html' }, ["Oops! no route for #{path}"]]
  end
end


# frozen_string_literal: true

class Route
  attr_reader :http_method, :path, :handler, :params_keys

  def initialize(http_method, path, handler, params_keys)
    @http_method = http_method
    @path = path
    @handler = handler
    @params_keys = params_keys
  end
end


# frozen_string_literal: true

module RouteMatcher
  def matching_segments?(route_segments, path_segments)
    route_segments.length == path_segments.length
  end

  def matching_route?(route_segments, path_segments)
    route_segments.zip(path_segments).all? do |route_seg, path_seg|
      route_seg.start_with?(':') || route_seg == path_seg
    end
  end

  def extract_params(_route, route_segments, path_segments)
    params = {}

    route_segments.zip(path_segments).each_with_index do |(route_seg, path_seg), _i|
      next unless route_seg.start_with?(':')

      param_key = route_seg[1..]
      params[param_key] = path_seg
    end

    params
  end
end


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


# frozen_string_literal: true

class Router
  include HTTPVerbs
  include RouteMatcher
  include Debug

  def initialize
    @routes = []
    @request_handler = RequestHandler.new(self)
  end

  def match(http_method, path, &handler)
    segments = path.split('/')
    params_keys = segments.select { |seg| seg.start_with?(':') }.map { |seg| seg[1..] }
    path = segments.join('/')

    route = Route.new(http_method, path, handler, params_keys)

    @routes << route

    # Debug output
    debug_output("Added route: method=#{http_method}, path=#{path}, block=#{handler}, params_keys=#{params_keys}")
  end

  def call(env)
    @request_handler.call(env)
  end

  def find_route(_method, path)
    path_segments = path.split('/')

    @routes.each do |route|
      route_segments = route.path.split('/')
      next unless matching_segments?(route_segments, path_segments)

      if matching_route?(route_segments, path_segments)
        params = extract_params(route, route_segments, path_segments)
        return [route, params]
      end
    end

    [nil, {}]
  end
end


# frozen_string_literal: true

require 'rspec'
require 'spec_helper'
require 'rack/test'
require_relative '../app' # Path to your Rack application file

RSpec.describe 'Route testing', type: :request do
  include Rack::Test::Methods

  def app
    App.router # Replace `MyApp` with your application class or instance
  end

  it 'routes GET / to the home page' do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to include('You are at Home!')
    # Add more expectations about the response here if needed
  end

  it 'routes GET /greet/:name to a greeting message with the provided name' do
    get '/greet/John'
    expect(last_response).to be_ok
    expect(last_response.body).to include('Hello, John!')
    # Add more expectations about the response here if needed
  end

  it 'routes GET /users/:user_id/posts/:post_id to the correct message with user and post IDs' do
    get '/users/123/posts/456'
    expect(last_response).to be_ok
    expect(last_response.body).to include('You are viewing post 456 of user 123!')
    # Add more expectations about the response here if needed
  end
end


# frozen_string_literal: true

# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause
# this file to always be loaded, without a need to explicitly require it in any
# files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need
# it.
#
# See https://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

require 'rack/test'
require_relative '../app'

RSpec.configure do |config|
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3). It causes shared context metadata to be
  # inherited by the metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # The settings below are suggested to provide a good initial experience
  # with RSpec, but feel free to customize to your heart's content.
  #   # This allows you to limit a spec run to individual examples or groups
  #   # you care about by tagging them with `:focus` metadata. When nothing
  #   # is tagged with `:focus`, all examples get run. RSpec also provides
  #   # aliases for `it`, `describe`, and `context` that include `:focus`
  #   # metadata: `fit`, `fdescribe` and `fcontext`, respectively.
  #   config.filter_run_when_matching :focus
  #
  #   # Allows RSpec to persist some state between runs in order to support
  #   # the `--only-failures` and `--next-failure` CLI options. We recommend
  #   # you configure your source control system to ignore this file.
  #   config.example_status_persistence_file_path = "spec/examples.txt"
  #
  #   # Limits the available syntax to the non-monkey patched syntax that is
  #   # recommended. For more details, see:
  #   # https://rspec.info/features/3-12/rspec-core/configuration/zero-monkey-patching-mode/
  #   config.disable_monkey_patching!
  #
  #   # This setting enables warnings. It's recommended, but in some cases may
  #   # be too noisy due to issues in dependencies.
  #   config.warnings = true
  #
  #   # Many RSpec users commonly either run the entire suite or an individual
  #   # file, and it's useful to allow more verbose output when running an
  #   # individual spec file.
  #   if config.files_to_run.one?
  #     # Use the documentation formatter for detailed output,
  #     # unless a formatter has already been configured
  #     # (e.g. via a command-line flag).
  #     config.default_formatter = "doc"
  #   end
  #
  #   # Print the 10 slowest examples and example groups at the
  #   # end of the spec run, to help surface which specs are running
  #   # particularly slow.
  #   config.profile_examples = 10
  #
  #   # Run specs in random order to surface order dependencies. If you find an
  #   # order dependency and want to debug it, you can fix the order by providing
  #   # the seed, which is printed after each run.
  #   #     --seed 1234
  #   config.order = :random
  #
  #   # Seed global randomization in this process using the `--seed` CLI option.
  #   # Setting this allows you to use `--seed` to deterministically reproduce
  #   # test failures related to randomization by passing the same `--seed` value
  #   # as the one that triggered the failure.
  #   Kernel.srand config.seed
end