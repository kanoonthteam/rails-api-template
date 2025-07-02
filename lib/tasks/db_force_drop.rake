# frozen_string_literal: true

namespace :db do
  desc "Force drop database by disconnecting all connections"
  task force_drop: :environment do
    db_name = ActiveRecord::Base.connection.current_database
    
    ActiveRecord::Base.connection.execute <<-SQL
      SELECT pg_terminate_backend(pg_stat_activity.pid)
      FROM pg_stat_activity
      WHERE pg_stat_activity.datname = '#{db_name}'
        AND pid <> pg_backend_pid();
    SQL
    
    ActiveRecord::Base.connection.disconnect!
    
    Rake::Task["db:drop"].invoke
  end
end