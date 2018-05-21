require 'sequel'
require 'sequel/extensions/honeycomb'

module Sequel
  module Honeycomb
    class << self
      def register!(honeycomb_client: nil, logger: nil)
        if honeycomb_client
          Sequel::Extensions::Honeycomb.client = honeycomb_client
        end
        if logger
          Sequel::Extensions::Honeycomb.logger = logger
        end

        Sequel::Database.extension :honeycomb
      end
    end
  end
end
