# frozen_string_literal: true

require 'date'
require 'graphd'

def client_stub
  @client_stub ||= Graphd::ClientStub.new('localhost:9080')
end

def client(client_stub)
  @client ||= Graphd::Client.new(client_stub)
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

# Deleting a data
def delete_data(client)
  # Create a new transaction.
  txn = client.txn
  query1 = "query all($a: string) {
            all(func: eq(name, $a)) {
               uid
            }
        }"
  variables1 = { '$a': 'Bob' }
  res1 = client.txn(read_only: true).query(query1, variables: variables1)
  ppl1 = JSON.parse(res1.json)

  ppl1['all'].each do |person|
    p "Bob's UID: #{person['uid']}"
    txn.mutate(del_obj: person)
    p 'Bob deleted'
    txn.commit
  end

  txn.discard
end

# Query for data.
def query_alice(client)
  # Run query.
  query = "query all($a: string) {
        all(func: eq(name, $a)) {
            uid
            name
            age
            married
            loc
            dob
            friend {
                name
                age
            }
            school {
                name
            }
        }
    }"

  variables = { '$a': 'Alice' }
  res = client.txn(read_only: true).query(query, variables: variables)
  ppl = JSON.parse(res.json)

  # Print results.
  p "Number of people named 'Alice': #{ppl['all'].length}"
end

# Query to check for deleted node
def query_bob(client)
  query = "query all($b: string) {
            all(func: eq(name, $b)) {
                uid
                name
                age
                friend {
                    uid
                    name
                    age
                }
                ~friend {
                    uid
                    name
                    age
                }
            }
        }"

  variables = { '$b': 'Bob' }
  res = client.txn(read_only: true).query(query, variables: variables)
  ppl = JSON.parse(res.json)

  # Print results.
  p "Number of people named 'Bob': #{ppl['all'].length}"
end

def upsert(client)
  txn = client.txn
  query = '{
        u as var(func: eq(name, "Jonas"))
  }'
  nquad = '
  uid(u) <name> "Jonas" .
  uid(u) <age> "25" .
'
  mutation = txn.create_mutation(set_nquads: nquad)
  request = txn.create_request(query: query, mutations: [mutation], commit_now: true)
  txn.do_request(request)
end

def cond_upsert(client)
  txn = client.txn
  query = '
        {
          user as var(func: eq(name, "Jonas"))
        }
  '
  cond = '@if(eq(len(user), 1))'
  nquads = '
         uid(user) <name> "Jonas Kahnwald" .
  '
  mutation = txn.create_mutation(cond: cond, set_nquads: nquads)
  request = txn.create_request(mutations: [mutation], query: query, commit_now: true)
  txn.do_request(request)
end

def run
  dgraph_client = client(client_stub)
  version = dgraph_client.check_version
  p version
  drop_all(dgraph_client)
  create_schema(dgraph_client)
  create_data(dgraph_client)
  query_alice(dgraph_client)
  query_bob(dgraph_client)
  delete_data(dgraph_client)
  query_alice(dgraph_client)
  query_bob(dgraph_client)
  upsert(dgraph_client)
  cond_upsert(dgraph_client)
end

run
