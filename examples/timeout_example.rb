# frozen_string_literal: true

require 'grpc'
require_relative '../lib/graphd'

def client_stub
  # if timeout is exceeded will throw `GRPC::DeadlineExceeded`
  @client_stub ||= Graphd::ClientStub.new('localhost:9080', timeout: 1)
end

def client(client_stub)
  @client ||= Graphd::Client.new(client_stub)
end

def run
  dgraph_client = client(client_stub)
  version = dgraph_client.check_version
  p version
end

run
