require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc "Run the cas_fuji specs and build the cover_me report"
task :spec do
  Rake::Task['cover_me:report'].invoke
end
