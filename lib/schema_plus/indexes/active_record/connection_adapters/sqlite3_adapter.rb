module SchemaPlus::Indexes
  module ActiveRecord
    module ConnectionAdapters
      module Sqlite3Adapter
        include ::SchemaPlus::Indexes::RemoveIfExists
      end
    end
  end
end
