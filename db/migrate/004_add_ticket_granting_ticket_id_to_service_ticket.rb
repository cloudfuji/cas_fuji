class AddTicketGrantingTicketIdToServiceTicket < ActiveRecord::Migration
  def self.up
    add_column :casfuji_st, :ticket_granting_ticket_id, :integer, :null => true
  end
  
  def self.down
    remove_column :casfuji_st, :ticket_granting_ticket_id
  end
end
  