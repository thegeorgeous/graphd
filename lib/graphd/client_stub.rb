# frozen_string_literal: true

require 'grpc'
require_relative 'api_services_pb'

module Graphd
  # gRPC Client stub for DGraph
  class ClientStub
    attr_reader :stub

    def initialize(
      host = 'localhost:9080',
      credentials = :this_channel_is_insecure,
      channel_args = {}
    )
      @stub = Api::Dgraph::Stub.new(host, credentials, channel_args)
    end

    def check_version(request)
      @stub.check_version(request)
    end

    def alter(operation)
      @stub.alter(operation)
    end

    def query(request)
      @stub.query(request)
    end

    def commit_or_abort(transaction_context:)
      @stub.commit_or_abort(transaction_context)
    end
  end
end
