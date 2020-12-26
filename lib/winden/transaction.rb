# frozen_string_literal: true

require 'json'

module Winden
  class Transaction
    def initialize(client, read_only: false)
      @client = client
      @client_stub = @client.client
      @transaction_context = ::Api::TxnContext.new
      @finished = false
      @mutated = false
      @read_only = read_only
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

    def create_mutation(mutation:, set_obj:, del_obj:)
      mutation ||= ::Api::Mutation.new

      mutation.set_json = set_obj.to_json if set_obj
      mutation.delete_json = del_obj.to_json if del_obj

      mutation
    end

    def create_request(query: nil, variables: nil, mutations: nil, commit_now: nil)
      request = ::Api::Request.new(start_ts: @transaction_context.start_ts, commit_now: commit_now)
      variables&.each do |key, value|
        if key.is_a?(String) && value.is_a?(String)
          raise TransactionError, 'Values and keys in variable map must be strings'
        end

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
