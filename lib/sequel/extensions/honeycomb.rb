module Sequel
  module Extensions
    module Honeycomb
      class << self
        attr_accessor :client

        def included(mod)
          # TODO ugh clean this up
          @client ||= begin
            if defined?(::Honeycomb.client)
              ::Honeycomb.client
            else
              raise "Can't work without magic global Honeycomb.client at the moment"
            end
          end
          mod.class_exec(@client) do |honeycomb_|
            define_method(:honeycomb) { honeycomb_ }
          end
        end
      end

      def execute(sql, opts=OPTS, &block)
        raise 'something went horribly wrong' unless honeycomb # TODO

        event = honeycomb.event

        event.add_field :table, first_source_table rescue nil
        event.add_field :sql, sql
        start = Time.now
        adding_span_metadata_if_available(event) do
          super
        end
      rescue Exception => e
        if event
          event.add_field :exception_class, e.class
          event.add_field :exception_message, e.message
        end
        raise
      ensure
        if start && event
          finish = Time.now
          duration = finish - start
          event.add_field :durationMs, duration * 1000
          event.send
        end
      end

      private
      def adding_span_metadata_if_available(event)
        return yield unless defined?(::Honeycomb.trace_id)

        trace_id = ::Honeycomb.trace_id
        name = first_source_table rescue 'sql'

        event.add_field :traceId, trace_id if trace_id
        span_id = SecureRandom.uuid
        event.add_field :id, span_id
        event.add_field :serviceName, 'sequel'
        event.add_field :name, name if name

        ::Honeycomb.with_span_id(span_id) do |parent_span_id|
          event.add_field :parentId, parent_span_id
          yield
        end
      end
    end

    Sequel::Dataset.register_extension(:honeycomb, Honeycomb)
  end
end
