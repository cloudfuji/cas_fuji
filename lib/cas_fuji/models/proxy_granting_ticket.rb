# CAS 3.3
class ProxyGrantingTicket < CasFuji::Models::BaseTicket
  # begins with "PGT-"
  set_table_name "casfuji_pgt"
end
