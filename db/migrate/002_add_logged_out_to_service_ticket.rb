class AddLoggedOutToServiceTicket < ActiveRecord::Migration
  def self.up
    add_column :casfuji_st, :logged_out, :boolean, :default => false 
  end
  
  def self.down
    remove_column :casfuji_st, :logged_out
  end
end