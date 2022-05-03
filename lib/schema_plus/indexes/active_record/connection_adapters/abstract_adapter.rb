# frozen_string_literal: true

module SchemaPlus::Indexes
  module ActiveRecord
    module ConnectionAdapters
      module AbstractAdapter
        include ::SchemaPlus::Indexes::RemoveIfExists
      end
    end
  end
end
