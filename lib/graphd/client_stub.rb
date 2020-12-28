# frozen_string_literal: true

require 'grpc'
require_relative 'api_services_pb'

module Graphd
  # gRPC Client stub for DGraph
  # This stub is a very thin wrapper over `GRPC::ClientStub`. It exists purely
  # to provide sensible defaults relevant to DGraph like host and credentials
  class ClientStub
    attr_reader :stub

    # Creates a new Graphd::ClientStub
    #
    # @param host [String] the host the stub connects to
    # @param creds [GRPC::Core::ChannelCredentials|Symbol] the channel credentials, or
    #     :this_channel_is_insecure, which explicitly indicates that the client
    #     should be created with an insecure connection. Note: this argument is
    #     ignored if the channel_override argument is provided.
    # @param channel_override [GRPC::Core::Channel] a pre-created channel
    # @param timeout [Number] the default timeout in milliseconds to use in requests
    #     This will be used to set the deadline for every call made using this stub
    # @param channel_args [Hash] the channel arguments. Note: this argument is
    #     ignored if the channel_override argument is provided.
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

    # Request the version of the DGraph server running on host
    #
    # @param request [Api::Check]
    # @return [Api::Version]
    def check_version(request)
      @stub.check_version(request)
    end

    # Run operations that alter the DGraph db like set schema and drop_all
    #
    # @param operation [Api::Operation]
    # @return [Api::Payload]
    def alter(operation)
      @stub.alter(operation)
    end

    # Query the db
    #
    # @param request [Api::Request]
    # @return [Api::Response]
    def query(request)
      @stub.query(request)
    end

    # Commit a mutation or abort if it fails
    #
    # @param transaction_context [Api::TxnContext]
    # @return [Api::TxnContext]
    def commit_or_abort(transaction_context:)
      @stub.commit_or_abort(transaction_context)
    end
  end
end
