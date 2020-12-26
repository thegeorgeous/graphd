# frozen_string_literal: true

# Raised when there are errors in the client, duh!
class ClientError < StandardError
  def initialize(msg = 'No client provided')
    super
  end
end
