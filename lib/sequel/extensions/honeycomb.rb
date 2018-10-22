module Sequel
  module Extensions
    module Honeycomb
      class << self
        attr_accessor :client
        attr_reader :builder
        attr_accessor :logger

        def included(klazz)
          @logger ||= ::Honeycomb.logger if defined?(::Honeycomb.logger)

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
        start = Time.now
        with_tracing_if_available(event, query_name(sql)) do
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

      def with_tracing_if_available(event, name)
        return yield unless defined?(::Honeycomb::Beeline::VERSION)

        ::Honeycomb.span_for_existing_event(event, name: name, type: 'db') do
          yield
        end
      end
    end

    Sequel::Dataset.register_extension(:honeycomb, Honeycomb)
  end
end
