# frozen_string_literal: true

module SchemaPlus::Indexes
  module ActiveRecord
    module Base
      module ClassMethods

        public

        # Returns a list of IndexDefinition objects, for each index
        # defined on this model's table.
        #
        def indexes
          @indexes ||= connection.indexes(table_name)
        end

        # (reset_index_information gets called by by Middleware::Model::ResetColumnInformation)
        def reset_index_information
          @indexes = nil
        end

      end
    end
  end
end

