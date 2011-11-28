Dir['tasks/**/*.rake'].each { |rake| load rake }

if ENV["RAILS_ENV"] != "production"
  require 'ci/reporter/rake/rspec'
end
