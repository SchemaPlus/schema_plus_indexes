module SchemaPlus::Indexes
  module RemoveIfExists
    # Extends rails' remove_index to include this options:
    #   :if_exists
    if Gem::Version.new(::ActiveRecord::VERSION::STRING) >= Gem::Version.new('5.1')
      def remove_index(table_name, *args)
        options = args.extract_options!
        if_exists = options.delete(:if_exists)
        args << options if options.any?
        return if if_exists && !index_name_exists?(table_name, options[:name] || index_name(table_name, *args))
        super table_name, *args
      end
    else
      def remove_index(table_name, *args)
        options = args.extract_options!
        if_exists = options.delete(:if_exists)
        args << options if options.any?
        return if if_exists && !index_name_exists?(table_name, options[:name] || index_name(table_name, *args), nil)
        super table_name, *args
      end
    end
  end
end
