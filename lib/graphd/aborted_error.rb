# lib/aborted_error.rb

module Graphd
  # Error thrown by aborted transaction
  class AbortedError < StandardError
    def initialize(msg = 'Transaction has been aborted. Please retry')
      super(msg)
    end
  end
end
