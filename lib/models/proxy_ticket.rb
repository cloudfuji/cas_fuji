# CAS 3.2
class ProxyTicket < ActiveRecord::Base
  # should begin with "PT-"
  set_table_name "casfuji_tgt"
end
