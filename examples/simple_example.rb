# frozen_string_literal: true

require_relative '../lib/winden'

def client_stub
  @client_stub ||= Winden::ClientStub.new('localhost:9080')
end

def client(client_stub)
  @client ||= Winden::Client.new(client_stub)
end

def drop_all(client)
  client.alter(::Api::Operation.new(drop_all: true))
end

def create_schema(client)
  schema = "
    name: string @index(exact) .
    friend: [uid] @reverse .
    age: int .
    married: bool .
    loc: geo .
    dob: datetime .
    type Person {
        name
        friend
        age
        married
        loc
        dob
    }
  "
  client.alter(::Api::Operation.new(schema: schema))
end

def run
  dgraph_client = client(client_stub)
  version = dgraph_client.check_version
  p version
  drop_all(dgraph_client)
  create_schema(dgraph_client)
end

run
