# frozen_string_literal: true

require 'grpc'
require_relative 'api_services_pb'

module Graphd
  # gRPC Client stub for DGraph
  # This stub is a very thin wrapper over `GRPC::ClientStub`. It exists purely
  # to provide sensible defaults relevant to DGraph like host and credentials
  class ClientStub
    attr_reader :stub

    def initialize(
      host = 'localhost:9080',
      credentials = :this_channel_is_insecure,
      channel_override: nil,
      timeout: nil,
      channel_args: {}
    )
      @stub = Api::Dgraph::Stub.new(
        host,
        credentials,
        channel_override: channel_override,
        timeout: timeout,
        channel_args: channel_args
      )
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
