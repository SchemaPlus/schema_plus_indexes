module SchemaPlus::Indexes
  module ActiveRecord
    module ConnectionAdapters

      module IndexDefinition

        def initialize(*args) #:nodoc:
          # same args as add_index(table_name, column_names, options)
          if args.length == 3 and Hash === args.last
            table_name, column_names, options = args + [{}]
            super table_name, options[:name], options[:unique], column_names, options[:length], options[:orders], options[:where], options[:type], options[:using]
          else # backwards compatibility
            super
          end
          unless orders.blank?
            # fill out orders with :asc when undefined.  make sure hash ordering
            # follows column ordering.
            self.orders = Hash[columns.map{|column| [column, orders[column] || :asc]}]
          end
        end

        # tests if the corresponding indexes would be the same
        def ==(other)
          return false if other.nil?
          return false unless self.name == other.name
          return false unless Array.wrap(self.columns).collect(&:to_s).sort == Array.wrap(other.columns).collect(&:to_s).sort
          return false unless !!self.unique == !!other.unique
          return false unless Array.wrap(self.lengths).compact.sort == Array.wrap(other.lengths).compact.sort
          return false unless self.where == other.where
          return false unless (self.using||:btree) == (other.using||:btree)
          true
        end
      end
    end
  end
end
