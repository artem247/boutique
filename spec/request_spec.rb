# frozen_string_literal: true

require 'rspec'
require_relative '../routes/request'

RSpec.describe Request do
  let(:env) { { 'HTTP_CONTENT_TYPE' => 'application/json', 'rack.input' => StringIO.new('{"key":"value"}') } }
  subject(:request) { Request.new(env) }

  context '#headers' do
    it 'formats header keys correctly' do
      expect(request.headers).to include('Content-Type' => 'application/json')
    end
  end

  context '#body_json' do
    it 'parses JSON body correctly' do
      expect(request.body_json).to eq({ 'key' => 'value' })
    end
  end
end
