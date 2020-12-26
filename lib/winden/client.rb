# frozen_string_literal: true

require_relative 'api_pb'

module Winden
  # Client initialized to talk to a DGraph instance
  # Accepts multiple instances of Winden::ClientStub
  # Examples:
  # client_stub = Winden::ClientStub.new('localhost:9080')
  # client = Winden::Cilent.new(client_stub)
  class Client
    def initialize(*clients)
      raise ClientError unless clients

      @clients = clients
      @jwt = Api::Jwt.new
    end

    def check_version
      request = Api::Check.new
      response = client.check_version(request)
      response.tag
    end

    def alter(operation)
      client.alter(operation)
    end

    private

    def client
      @clients.sample
    end
  end
end
