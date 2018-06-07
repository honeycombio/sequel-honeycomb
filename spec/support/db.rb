require 'sequel'
require 'yaml'

require 'sequel/honeycomb'

require 'support/fakehoney'

DATABASE_DRIVER = 'pg'
require DATABASE_DRIVER

module TestDB
  CONFIG_FILE = File.expand_path('db/config.yml', File.dirname(__FILE__))
  class << self
    attr_reader :db

    def config
      @config ||= YAML.parse_file(CONFIG_FILE).to_ruby[DATABASE_DRIVER]
    end

    def connect!
      Sequel::Honeycomb.install! client: $fakehoney

      @db ||= Sequel.connect(**config)
    end

    def disconnect!
      @db.disconnect if @db
      @db = nil
    end

    def create_tables!
      db.create_table :animals do
        primary_key :id
        String :name
        String :species, null: false
        DateTime :created_at
        DateTime :updated_at
      end
    end

    def Animals
      @animals ||= db[:animals]
    end
  end
end
