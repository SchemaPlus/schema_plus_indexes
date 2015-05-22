require 'spec_helper'

module AddIndexBefore
  module Middleware
    module Migration
      module Column
        include Enableable

        def before(env)
          env.options[:index] = { name: 'whatever' } if enabled_middleware(AddIndexBefore, env)
        end
      end
    end
  end
end

SchemaMonkey.register AddIndexBefore

describe "Command Recorder" do

  before(:each) do
      define_schema do
        create_table "comments" do |t|
          t.integer :column
        end
      end
  end

  context "with add-index-before middleware enabled" do
    let(:middleware) { AddIndexBefore::Middleware::Migration::Column }
    around(:each) do |example|
      begin
        example.run
      ensure
        middleware.disable
      end
    end

    it "does not fail when reverting" do
      migration = Class.new ::ActiveRecord::Migration do
        define_method(:change) {
          change_table("comments") do |t|
            t.integer :column
          end
        }
      end
      middleware.enable
      expect { migration.migrate(:down) }.not_to raise_error
    end
  end

end
