# frozen_string_literal: true

module SchemaPlus::Indexes
  module Middleware
    module Migration

      module Column

        # Shortcuts
        def before(env)
          case env.options[:index]
          when true then env.options[:index] = {}
          when :unique then env.options[:index] = { :unique => true }
          end
        end

        # Support :index option in Migration.add_column
        def after(env)
          return unless env.options[:index]
          case env.operation
          when :add, :record
            env.caller.add_index(env.table_name, env.column_name, env.options[:index])
          end
        end
      end

      module Index

        # Normalize Args
        def before(env)
          [:length, :order].each do |key|
            env.options[key].stringify_keys! if env.options[key].is_a? Hash
          end
          env.column_names = Array.wrap(env.column_names).map(&:to_s) + Array.wrap(env.options.delete(:with)).map(&:to_s)
        end

        # Ignore duplicates
        #
        # SchemaPlus::Indexes modifies SchemaStatements::add_index so that it ignores
        # errors raised about add an index that already exists -- i.e. that has
        # the same index name, same columns, and same options -- and writes a
        # warning to the log. Some combinations of rails & DB adapter versions
        # would log such a warning, others would raise an error; with
        # SchemaPlus::Indexes all versions log the warning and do not raise the error.
        def around(env)
          yield env
        rescue => e
          raise unless e.message.match(/["']([^"']+)["'].*already exists/)

          name = $1
          existing = env.caller.indexes(env.table_name).find{|i| i.name == name}
          attempted = ::ActiveRecord::ConnectionAdapters::IndexDefinition.new(
            env.table_name, name, env.options[:unique], env.column_names,
            **env.options.except(:unique)
          )
          raise if attempted != existing
          ::ActiveRecord::Base.logger.warn "[schema_plus_indexes] Index name #{name.inspect}' on table #{env.table_name.inspect} already exists. Skipping."
        end
      end

    end
  end
end
