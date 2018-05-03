module Sequel
  module Honeycomb
    module AutoInstall
      class << self
        def available?(**_)
          gem 'sequel'
          true
        rescue Gem::LoadError
          false
        end

        def auto_install!(honeycomb_client:, logger: nil)
          require 'sequel'
          require 'sequel/extensions/honeycomb'

          # TODO is this the right way?
          # TODO inject client
          Sequel::Database.extension :honeycomb
        end
      end
    end
  end
end
