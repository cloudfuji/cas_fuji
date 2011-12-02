module CasFuji
  module Models
    class BaseTicket < ActiveRecord::Base
      establish_connection(CasFuji.config[:database])
    end
  end
end
