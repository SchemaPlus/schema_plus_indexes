require 'simplecov'

SimpleCov.start

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rspec'
require 'active_record'
require 'schema_plus_indexes'
require 'schema_dev/rspec'

SchemaDev::Rspec.setup

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.include(SchemaPlus::IndexesMatchers)
  config.warnings = true
  config.around(:each) do |example|
    ActiveRecord::Migration.suppress_messages do
      example.run
    end
  end
end

# shim to handle connection.tables deprecation in favor of
# connection.data_sources
def each_table(connection)
  (connection.try :data_sources || connection.tables).each do |table|
    yield table
  end
end

def define_schema(config={}, &block)
  ActiveRecord::Schema.define do
    each_table(connection) do |table|
      drop_table table, :force => :cascade
    end
    instance_eval &block
  end
end

SimpleCov.command_name "[ruby #{RUBY_VERSION} - ActiveRecord #{::ActiveRecord::VERSION::STRING} - #{ActiveRecord::Base.connection.adapter_name}]"

