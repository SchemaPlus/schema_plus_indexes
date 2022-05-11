# frozen_string_literal: true

module SchemaPlus::Indexes
  module RemoveIfExists
    if Gem::Version.new(::ActiveRecord::VERSION::STRING) < Gem::Version.new('6.1')
      # Extends rails' remove_index to include this options:
      #   :if_exists
      def remove_index(table_name, *args)
        options = args.extract_options!
        if_exists = options.delete(:if_exists)
        args << options if options.any?
        return if if_exists && !index_name_exists?(table_name, options[:name] || index_name(table_name, *args))
        super table_name, *args
      end
    else
      # Extends rails' remove_index to include this options:
      #   :if_exists
      def remove_index(table_name, column_name = nil, other = nil, **options)
        if_exists = options.delete(:if_exists)
        return if if_exists && !index_name_exists?(table_name, options[:name] || index_name(table_name, column_name || options))
        super table_name, column_name, **options
      end
    end
  end
end
