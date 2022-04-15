module SchemaPlus::Indexes
  module ActiveRecord
    module ConnectionAdapters

      module IndexDefinition
        attr_accessor :orders

        def initialize(*args, **kwargs) #:nodoc:
          super

          unless orders.blank?
            # fill out orders with :asc when undefined.  make sure hash ordering
            # follows column ordering.
            if self.orders.is_a?(Hash)
              self.orders = Hash[columns.map{|column| [column, orders[column] || :asc]}]
            else
              self.orders = Hash[columns.map{|column| [column, orders || :asc]}]
            end
          end
        end

        # tests if the corresponding indexes would be the same
        def ==(other)
          return false if other.nil?
          return false unless self.name == other.name
          return false unless Array.wrap(self.columns).collect(&:to_s).sort == Array.wrap(other.columns).collect(&:to_s).sort
          return false unless !!self.unique == !!other.unique
          return false if (self.lengths || {}) != (other.lengths || {}) # treat nil same as empty hash
          return false unless self.where == other.where
          return false unless (self.using||:btree) == (other.using||:btree)
          true
        end
      end
    end
  end
end
