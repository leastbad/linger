module Linger::Authentication
  extend ActiveSupport::Concern

  def authenticate_connection!
    identifier_exists = false
    Linger.instrument :meta, message: "Verifing #{connection.connection_identifier}" do
      identifier_exists = Linger.redis.exists?(connection.connection_identifier)
    end
    throw :forbidden unless identifier_exists
  end
end
