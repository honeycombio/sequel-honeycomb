module Sequel
  module Honeycomb
    module AutoInstall
      class << self
        def available?(logger: nil)
          gem 'sequel'
          logger.debug "#{self.name}: detected sequel, okay to autoinitialise" if logger
          true
        rescue Gem::LoadError => e
          logger.debug "Didn't detect Sequel (#{e.class}: #{e.message}), not autoinitialising sequel-honeycomb" if logger
          false
        end

        def auto_install!(honeycomb_client:, logger: nil)
          require 'sequel/honeycomb'

          Sequel::Honeycomb.install!(client: honeycomb_client, logger: logger)
        end
      end
    end
  end
end
