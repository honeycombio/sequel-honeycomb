# only define this module if the Sequel constant is already defined (by way of
# having the sequel gem installed) or if this gem has been included by an older
# version of the beeline which is not able to handle this module not existing
if (defined? Sequel) || (Gem::Version.new(Honeycomb::Beeline::VERSION) <= Gem::Version.new("0.6.0"))
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
end
