# frozen_string_literal: true

require_relative 'api_pb'
require_relative 'transaction'

module Graphd
  # Client initialized to talk to a DGraph instance. Accepts multiple instances
  # of Graphd::ClientStub
  #
  # Examples:
  #
  #   client_stub = Graphd::ClientStub.new('localhost:9080')
  #   client = Graphd::Cilent.new(client_stub)
  class Client
    # Create a new instance of Graphd::Client
    #
    # @param clients [Array<Graphd::ClientStub>] The stubs that can be used
    #     to communicate with a DGraph server
    def initialize(*clients)
      raise ClientError unless clients

      @clients = clients
      @jwt = Api::Jwt.new
    end

    # Get the version of the DGraph server
    #
    # @return [String] the version of the DGraph server
    def check_version
      request = Api::Check.new
      response = client.check_version(request)
      response.tag
    end

    # Execute an alter operation
    def alter(operation)
      client.alter(operation)
    end

    # Create a new transaction
    #
    # @param read_only [true, false] whether the transaction should be read only
    # @param best_effort [true, false] Enable best-effort queries for the transaction
    #
    # @return [Transaction]
    def txn(read_only: false, best_effort: false)
      Transaction.new(self, read_only: read_only, best_effort: best_effort)
    end

    # Return a random stub from the list of stubs provided so that requests are
    # evenly distributed between them
    def client
      @clients.sample
    end
  end
end
