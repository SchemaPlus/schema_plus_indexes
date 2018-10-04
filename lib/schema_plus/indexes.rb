require 'schema_plus/core'
require 'its-it'
require 'active_record'

if Gem::Version.new(ActiveRecord::VERSION::STRING) >= Gem::Version.new('5.2.0')
  require_relative 'indexes/remove_if_exists_5_2'
  require_relative 'indexes/active_record/connection_adapters/index_definition_5_2'
else
  require_relative 'indexes/remove_if_exists'
  require_relative 'indexes/active_record/connection_adapters/index_definition'
end

require_relative 'indexes/active_record/base'
require_relative 'indexes/active_record/connection_adapters/abstract_adapter'
require_relative 'indexes/active_record/connection_adapters/postgresql_adapter'
require_relative 'indexes/active_record/connection_adapters/sqlite3_adapter'
require_relative 'indexes/active_record/migration/command_recorder'
require_relative 'indexes/middleware/dumper'
require_relative 'indexes/middleware/migration'
require_relative 'indexes/middleware/model'
require_relative 'indexes/middleware/schema'

SchemaMonkey.register SchemaPlus::Indexes
