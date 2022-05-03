# frozen_string_literal: true

module SchemaPlus::Indexes
  module Middleware
    module Model
      module ResetColumnInformation
        def after(env)
          env.model.reset_index_information
        end
      end
    end
  end
end
