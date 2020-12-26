# lib/aborted_error.rb

module Winden
  # Error thrown by aborted transaction
  class AbortedError < StandardError
    def initialize(msg = 'Transaction has been aborted. Please retry')
      super(msg)
    end
  end
end
