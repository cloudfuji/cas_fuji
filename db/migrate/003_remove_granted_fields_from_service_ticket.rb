class RemoveGrantedFieldsFromServiceTicket < ActiveRecord::Migration
  def self.up
    remove_column :casfuji_st, :granted_by_pgt_id
    remove_column :casfuji_st, :granted_by_tgt_id
  end
  
  def self.down
    add_column :casfuji_st, :granted_by_pgt_id, :integer, :null => true
    add_column :casfuji_st, :granted_by_tgt_id, :integer, :null => true
  end
end
