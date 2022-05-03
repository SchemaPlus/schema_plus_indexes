# frozen_string_literal: true

module SchemaPlus::Indexes
  module ActiveRecord
    module Migration
      module CommandRecorder

        # inversion of add_index will be remove_index.  add if_exists
        # option for cases where the index doesn't actually exist
        def invert_add_index(args)
          super.tap { |(command, (arg, options))|
            options[:if_exists] = true
          }
        end
      end
    end
  end
end
