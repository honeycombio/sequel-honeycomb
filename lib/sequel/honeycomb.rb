require 'sequel'
require 'sequel/extensions/honeycomb'

module Sequel
  module Honeycomb
    class << self
      def register!(honeycomb_client: nil)
        if honeycomb_client
          Sequel::Extensions::Honeycomb.client = honeycomb_client
        end

        Sequel::Database.extension :honeycomb
      end
    end
  end
end
