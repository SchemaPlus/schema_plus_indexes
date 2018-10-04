module SchemaPlus::Indexes
  module ActiveRecord
    module ConnectionAdapters

      module IndexDefinition
        attr_accessor :orders

        def initialize(*args) #:nodoc:
          # same args as add_index(table_name, column_names, options)
          if args.length == 3 and Hash === args.last
            table_name, column_names, options = args + [{}]
            super(
              table_name, options[:name], options[:unique], column_names,
              lengths: options[:length] || {},
              orders: options[:orders] || {},
              where: options[:where],
              type: options[:type],
              using: options[:using]
            )
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
          if self.lengths.is_a?(Hash) or other.lengths.is_a?(Hash)
            return false if (self.lengths || {}) != (other.lengths || {}) # treat nil same as empty hash
          else
            return false if Array.wrap(self.lengths).compact.sort != Array.wrap(other.lengths).compact.sort
          end
          return false unless self.where == other.where
          return false unless (self.using||:btree) == (other.using||:btree)
          true
        end
      end
    end
  end
end
