# frozen_string_literal: true

require 'date'
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

def create_data(client)
  # Create a new transaction.
  txn = client.txn
  # Create data.
  p = {
    'uid': '_:alice',
    'dgraph.type': 'Person',
    'name': 'Alice',
    'age': 26,
    'married': true,
    'loc': {
      'type': 'Point',
      'coordinates': [1.1, 2]
    },
    'dob': DateTime.new(1980, 1, 1, 23, 0, 0, 0),
    'friend': [
      {
        'uid': '_:bob',
        'dgraph.type': 'Person',
        'name': 'Bob',
        'age': 24
      }
    ],
    'school': [
      {
        'name': 'Crown Public School'
      }
    ]
  }
  # Run mutation.
  response = txn.mutate(set_obj: p)

  # Commit transaction.
  txn.commit

  # Get uid of the outermost object (person named "Alice").
  # response.uids returns a map from blank node names to uids.
  p "Created person named 'Alice' with uid = #{response.uids[:alice]}"

  # Clean up. Calling this after txn.commit() is a no-op and hence safe.
  txn.discard
end

def run
  dgraph_client = client(client_stub)
  version = dgraph_client.check_version
  p version
  drop_all(dgraph_client)
  create_schema(dgraph_client)
  create_data(dgraph_client)
end

run
