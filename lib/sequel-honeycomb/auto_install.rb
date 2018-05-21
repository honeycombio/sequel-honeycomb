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
          require 'sequel/honeycomb'

          Sequel::Honeycomb.register!(honeycomb_client: honeycomb_client, logger: logger)
        end
      end
    end
  end
end
