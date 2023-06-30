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


  it 'routes GET /* to a wildcard route' do
    get '/any/path/you/want'
    expect(last_response).to be_ok
    expect(last_response.body).to include('Wildcard path: /any/path/you/want')
    # Add more expectations about the response here if needed
  end

end
