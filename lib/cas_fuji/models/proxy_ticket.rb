# CAS 3.2
class ProxyTicket < CasFuji::Models::BaseTicket
  # should begin with "PT-"
  set_table_name "casfuji_tgt"
end
