module SchemaPlus::Indexes
  module Middleware
    module Schema
      module Sqlite3
        module Indexes

          def after(env)
            indexes = Hash[env.index_definitions.map{ |d| [d.name, d] }]

            env.connection.exec_query("SELECT name, sql FROM sqlite_master WHERE type = 'index'").map do |row|
              if row['sql'] && (desc_columns = row['sql'].scan(/['"`]?(\w+)['"`]? DESC\b/).flatten).any?
                index = indexes[row['name']]
                index.orders = Hash[index.columns.map {|column| [column, desc_columns.include?(column) ? :desc : :asc]}]
              end
            end
          end
        end
      end
    end
  end
end
