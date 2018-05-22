require 'bump/tasks'
require 'rspec/core/rake_task'
require 'yard'

YARD::Rake::YardocTask.new(:doc)

namespace :spec do
  namespace :db do
    task :connection do
      $: << 'spec'
      require 'support/db'

      TestDB.connect!
    end

    desc 'Set up the test database schema'
    task setup_schema: :connection do
      TestDB.create_tables!
    end
  end
end

RSpec::Core::RakeTask.new(:spec)

task default: :spec
