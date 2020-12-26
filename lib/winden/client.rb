# frozen_string_literal: true

require_relative 'api_pb'
require_relative 'transaction'

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

    def txn(read_only: false)
      Transaction.new(self, read_only: read_only)
    end

    def client
      @clients.sample
    end
  end
end
