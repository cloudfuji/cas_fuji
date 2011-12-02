$LOAD_PATH << './lib'

require 'logger'
require 'cas_fuji'
require 'active_record'

namespace :casfuji do
  namespace :db do
    task :config do
      puts "DB CONFIG: #{CasFuji.config[:database]}"
      ActiveRecord::Migration.verbose = true
      ActiveRecord::Base.logger = Logger.new(STDOUT)
      #ActiveRecord::Base.establish_connection(CasFuji.config[:database].merge('database' => 'template1'))
    end

    desc "creates the database (options CAS_FUJI_CONFIG=/path/to/config.yml)"
    task :create => :config do
      ActiveRecord::Base.establish_connection(CasFuji.config[:database].merge('database' => 'template1'))
      ActiveRecord::Base.connection.create_database(CasFuji.config[:database]["database"], CasFuji.config[:database])
    end
    
    desc "drops the database (options CAS_FUJI_CONFIG=/path/to/config.yml)"
    task :drop => :config do
      ActiveRecord::Base.establish_connection(CasFuji.config[:database].merge('database' => 'template1'))
      ActiveRecord::Base.connection.drop_database(CasFuji.config[:database]["database"])
    end

    desc "Bring your CasFuji server database schema up to date (options CAS_FUJI_CONFIG=/path/to/config.yml)"
    # task :migrate => :config do |t|
    #   #CASServer::Model::Base.logger = Logger.new(STDOUT)
    #   ActiveRecord::Migration.verbose = true
    #   puts ActiveRecord::Migrator.method(:migrate).source_location
    #   ActiveRecord::Migrator.migrate("lib/db/migrate")
    # end

    desc "runs the migrations (options CAS_FUJI_CONFIG=/path/to/config.yml)"
    task :migrate do
      ActiveRecord::Base.establish_connection(CasFuji.config[:database])
      ap ActiveRecord::Base.connection.inspect
      ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    end
  end
end
