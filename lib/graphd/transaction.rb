# frozen_string_literal: true

require 'json'
require_relative 'transaction_error'

module Graphd
  # A transaction to perform queries and mutations
  #
  # A transaction bounds a sequence of queries and mutations that are committed
  # by Dgraph as a single unit: that is, on commit, either all the changes are
  # accepted by Dgraph or none are.
  class Transaction
    # Create a new transaction
    #
    # @param client [Graphd::Client] The client for which the transaction needs to be created
    # @param read_only [true, false] whether the transaction should be read only
    #     Read-only transactions are ideal for transactions which only involve
    #     queries. Mutations and commits are not allowed.
    # @param best_effort [true, false] Enable best-effort queries Best-effort
    #     queries are faster than normal queries because they bypass the normal
    #     consensus protocol. For this same reason, best-effort queries cannot
    #     guarantee to return the latest data. Best-effort queries are only
    #     supported by read-only transactions.
    def initialize(client, read_only: false, best_effort: false)
      if !read_only && best_effort
        raise TransactionError, 'Best effort transactions are only compatible with read-only transactions'
      end

      @client = client
      @client_stub = @client.client
      @transaction_context = ::Api::TxnContext.new
      @finished = false
      @mutated = false
      @read_only = read_only
      @best_effort = best_effort
    end

    def mutate(mutation: nil, set_obj: nil, del_obj: nil, commit_now: nil)
      request_mutation = create_mutation(mutation: mutation, set_obj: set_obj, del_obj: del_obj)
      commit_now ||= request_mutation.commit_now
      request = create_request(mutations: [request_mutation], commit_now: commit_now)
      do_request(request)
    end

    def query(query, variables: nil)
      request = create_request(query: query, variables: variables)
      do_request(request)
    end

    # Create or modify an instance of Api::Mutation with the provided configuration
    #
    # @param mutation [Api::Mutation] (optional) A mutation to be modified
    # @param set_obj [Hash] (optional) A Hash that represent a value to be set
    #     This value will be set the value of `set_json` of `Api::Mutation`
    # @param del_obj [Hash] (optional) A Hash that represents a value to be deleted
    #     This value will be set the value of `delete_json` of `Api::Mutation`
    # @param set_nquads [String] (optional) An N-Quad representing the value to be set for `Api::Mutation`
    # @param del_nquads [String] (optional) An N-Quad representing the value to be deleted for `Api::Mutation`
    #
    # @return [Api::Mutation]
    def create_mutation(mutation: nil, set_obj: nil, del_obj: nil, set_nquads: nil, del_nquads: nil, cond: nil)
      mutation ||= ::Api::Mutation.new

      mutation.set_json = set_obj.to_json if set_obj
      mutation.delete_json = del_obj.to_json if del_obj
      mutation.set_nquads = set_nquads if set_nquads
      mutation.del_nquads = del_nquads if del_nquads
      mutation.cond = cond if cond

      mutation
    end

    # Create an instance of Api::Request
    #
    # @param query [String] (optional) A GraphQL query as a string
    # @param query [Hash] (optional) A Hash of variables used in the provided query
    #     The keys can be symbols or strings but not numbers. The values must be
    #     strings
    # @param mutations [Array<Api::Mutation>] A list of mutations
    # @param commit_now [true, false] Indicate that the mutation must be
    #     immediately committed. This can be used when the mutation needs to be
    #     committed, without querying anything further.
    #
    # @return [Api::Request]
    def create_request(query: nil, variables: nil, mutations: nil, commit_now: nil)
      request = ::Api::Request.new(
        start_ts: @transaction_context.start_ts,
        commit_now: commit_now,
        read_only: true,
        best_effort: true
      )
      variables&.each do |key, value|
        unless key.is_a?(Symbol) || key.is_a?(String)
          raise TransactionError, 'Keys in variable map must be symbols or strings'
        end

        raise TransactionError, 'Values in variable map must be strings' unless value.is_a?(String)

        request.vars[key] = value
      end

      request.query = query if query
      request.mutations += mutations if mutations

      request
    end

    def do_request(request)
      raise TransactionError, 'Transaction has already been committed or discarded' if @finished

      if request.mutations.length.positive?
        raise TransactionError, 'Readonly transaction cannot run mutations' if @read_only

        @mutated = true
      end

      query_error = nil

      begin
        @response = @client_stub.query(request)
      rescue StandardError => e
        query_error = e
      end

      discard if query_error

      @finished = true if request.commit_now

      merge_context(@response.txn)

      @response
    end

    def discard
      return unless common_discard

      @client_stub.commit_or_abort(transaction_context: @transaction_context)
    end

    def merge_context(src = nil)
      # This condition will be true only if the server doesn't return a
      # txn context after a query or mutation.
      return unless src

      if @transaction_context.start_ts.zero?
        @transaction_context.start_ts = src.start_ts
      elsif @transaction_context.start_ts != src.start_ts
        # This condition should never be true.
        raise TransactionError, 'StartTs mismatch'
      end

      @transaction_context.keys += src.keys
      @transaction_context.preds += src.preds
    end

    def commit
      return unless common_commit

      begin
        @client_stub.commit_or_abort(transaction_context: @transaction_context)
      rescue StandardError => e
        common_except_commit(e)
      end
    end

    private

    def common_discard
      return false if @finished

      @finished = true
      return false unless @mutated

      @transaction_context.aborted = true
      true
    end

    def common_commit
      raise TransactionError, 'Readonly transaction cannot run mutations or be committed' if @read_only

      raise TransactionError, 'Transaction has already been committed or discarded' if @finished

      @finished = true
      @mutated
    end

    def common_except_commit(error)
      raise error
    end
  end
end
