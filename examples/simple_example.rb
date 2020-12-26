# frozen_string_literal: true

require_relative '../lib/winden'

def client_stub
  Winden::ClientStub.new('localhost:9080')
end

def client(client_stub)
  Winden::Client.new(client_stub)
end

def run
  dgraph_client = client(client_stub)
  version = dgraph_client.check_version
  p version
end

run
