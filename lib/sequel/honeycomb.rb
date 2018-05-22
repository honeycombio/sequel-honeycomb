require 'sequel'
require 'sequel/extensions/honeycomb'

module Sequel
  module Honeycomb
    class << self
      def register!(client: nil)
        if client
          Sequel::Extensions::Honeycomb.client = client
        end

        Sequel::Database.extension :honeycomb
      end
    end
  end
end
