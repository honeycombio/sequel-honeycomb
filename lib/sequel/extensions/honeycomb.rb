module Sequel
  module Extensions
    module Honeycomb
      class << self
        attr_accessor :client
        attr_reader :builder
        attr_accessor :logger

        def included(klazz)
          if @client
            debug "initialized with #{@client.class.name} explicitly provided"
          elsif defined?(::Honeycomb.client)
            debug "initialized with #{::Honeycomb.client.class.name} from honeycomb-beeline"
            @client = ::Honeycomb.client
          else
            raise "Please set #{self.name}.client before using this extension"
          end

          @builder ||= @client.builder.add(
            'meta.package' => 'sequel',
            'meta.package_version' => Sequel::VERSION,
            'type' => 'db',
          )
        end

        private
        def debug(msg)
          @logger.debug("#{self.name}: #{msg}") if @logger
        end
      end

      def builder
        Sequel::Extensions::Honeycomb.builder
      end

      def execute(sql, opts=OPTS, &block)
        event = builder.event

        event.add_field 'db.table', first_source_table.to_s rescue nil
        event.add_field 'db.sql', sql
        event.add_field 'name', query_name(sql)
        start = Time.now
        adding_span_metadata_if_available(event) do
          super
        end
      rescue Exception => e
        if event
          event.add_field 'db.error', e.class.name
          event.add_field 'db.error_detail', e.message
        end
        raise
      ensure
        if start && event
          finish = Time.now
          duration = finish - start
          event.add_field 'duration_ms', duration * 1000
          event.send
        end
      end

      private
      def query_name(sql)
        sql.sub(/\s+.*/, '').upcase
      end

      def adding_span_metadata_if_available(event)
        return yield unless defined?(::Honeycomb.trace_id)

        trace_id = ::Honeycomb.trace_id

        event.add_field 'trace.trace_id', trace_id if trace_id
        span_id = SecureRandom.uuid
        event.add_field 'trace.span_id', span_id

        ::Honeycomb.with_span_id(span_id) do |parent_span_id|
          event.add_field 'trace.parent_id', parent_span_id
          yield
        end
      end
    end

    Sequel::Dataset.register_extension(:honeycomb, Honeycomb)
  end
end
