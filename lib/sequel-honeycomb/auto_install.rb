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
          # some gems use the presence of the Sequel module to determine if Sequel is in
          # use by the application. If we can't require the gem then we need to remove
          # the constant that we define so that other gems don't make bad assumptions
          Object.send(:remove_const, "Sequel")
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
