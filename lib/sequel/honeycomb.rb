require 'sequel'
require 'sequel/extensions/honeycomb'

module Sequel
  module Honeycomb
    class << self
      def install!(client: nil, logger: nil)
        if client
          Sequel::Extensions::Honeycomb.client = client
        end
        if logger
          Sequel::Extensions::Honeycomb.logger = logger
        end

        Sequel::Database.extension :honeycomb
      end
    end
  end
end
