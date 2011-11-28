$LOAD_PATH << './lib'

require 'logger'
require 'cas_fuji'
require 'sinatra/activerecord/rake'

namespace :casfuji do
  namespace :db do
    task :config do 
      require './lib/cas_fuji'
      ActiveRecord::Migration.verbose = true
      ActiveRecord::Base.logger = Logger.new(STDOUT)
      ActiveRecord::Base.establish_connection(CasFuji.config[:database])
      ap CasFuji.config[:database]
    end

    task :create => :config do
      ActiveRecord::Base.connection.create_database(CasFuji.config[:database])
    end

    task :drop => :config do
      ActiveRecord::Base.connection.drop_database(CasFuji.config[:database])
    end

    desc "Bring your CasFuji server database schema up to date (options CAS_FUJI_CONFIG=/path/to/config.yml)"
    task :migrate => :config do |t|
      #CASServer::Model::Base.logger = Logger.new(STDOUT)
      ActiveRecord::Migration.verbose = true
      ActiveRecord::Migrator.migrate("lib/db/migrate")
    end
  end
end
