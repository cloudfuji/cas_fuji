class CreateInitialStructure < ActiveRecord::Migration
  def self.up
    # Oracle table names cannot exceed 30 chars...
    # See http://code.google.com/p/rubycas-server/issues/detail?id=15
    create_table 'casfuji_lt', :force => true do |t|
      t.string    'name',            :null => false
      t.timestamp 'created_on',      :null => false
      t.datetime  'consumed',        :null => true
      t.string    'client_hostname', :null => false
    end

    create_table 'casfuji_st', :force => true do |t|
      t.string    'name',              :null => false
      t.text      'service',           :null => false
      t.timestamp 'created_on',        :null => false
      t.datetime  'consumed',          :null => true
      t.string    'client_hostname',   :null => false
      t.string    'permanent_id',      :null => false
      t.integer   'granted_by_pgt_id', :null => true
      t.integer   'granted_by_tgt_id', :null => true
    end

    create_table 'casfuji_tgt', :force => true do |t|
      t.string    'name',           :null => false
      t.timestamp 'created_on',       :null => false
      t.string    'client_hostname',  :null => false
      t.string    'permanent_id',     :null => false
      t.text      'extra_attributes', :null => true
    end

    create_table 'casfuji_pgt', :force => true do |t|
      t.string    'name',            :null => false
      t.timestamp 'created_on',        :null => false
      t.string    'client_hostname',   :null => false
      t.string    'iou',               :null => false
      t.integer   'service_ticket_id', :null => false
    end
  end # self.up

  def self.down
    drop_table 'casfuji_pgt'
    drop_table 'casfuji_tgt'
    drop_table 'casfuji_st'
    drop_table 'casfuji_lt'
  end # self.down
end
