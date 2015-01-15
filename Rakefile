require 'data_mapper'
require './server.rb'

task :auto_upgrade do
  DataMapper.auto_upgrade!
  puts "Auto-upgrade complete (no data loss)"
end

task :auto_migrate do
  DataMapper.auto_migrate!
  puts "Auto-migrate complete (data could have been lost)"
end

#should make a data_mapper_setup within an app folder, where server.rb will also be added
