[![Gem Version](https://badge.fury.io/rb/schema_plus_indexes.svg)](http://badge.fury.io/rb/schema_plus_indexes)
[![Build Status](https://secure.travis-ci.org/SchemaPlus/schema_plus_indexes.svg)](http://travis-ci.org/SchemaPlus/schema_plus_indexes)
[![Coverage Status](https://img.shields.io/coveralls/SchemaPlus/schema_plus_indexes.svg)](https://coveralls.io/r/SchemaPlus/schema_plus_indexes)
[![Dependency Status](https://gemnasium.com/lomba/schema_plus_indexes.svg)](https://gemnasium.com/SchemaPlus/schema_plus_indexes)

# schema_plus_indexes

Schema_plus_index adds various convenient capabilities to `ActiveRecord`'s index handling:

* Adds shorthands to the `:index` option in migrations

        create_table :parts do |t|
          t.string :role,             index: true     # shorthand for index: {}
          t.string :product_code,     index: :unique  # shorthand for index: { unique: true }
          t.string :first_name
          t.string :last_name,        index: { with: :first_name }  # multi-column index

          t.string :country_code
          t.string :area_code
          t.string :local_number,     index: { with: [:country_code, :area_code] } # multi-column index
        end

  Of course options can be combined, such as `index: { with: :first_name, unique: true, name: "my_index"}`

* Ensures that the `:index` option is respected by `Migration.add_column` and in `Migration.change_table`

* Adds `:if_exists` option to `ActiveRecord::Migration.remove_index`

* Provides consistent behavior regarding attempted duplicate index
  creation: Ignore and log a warning.  Different versions of Rails with
  different db adapters otherwise behave inconsistently: some ignore the
  attempt, some raise an error.

* `Model.indexes` returns the indexes defined for the `ActiveRecord` model.
  Shorthand for `connection.indexes(Model.table_name)`; the value is cached
  until the next time `Model.reset_column_information` is called

* In the schema dump `schema.rb`, index definitions are included within the
  `create_table` statements rather than added afterwards

* When using SQLite3, makes sure that the definitions returned by
  `connection.indexes` properly include the column orders (`:asc` or `:desc`)

schema_plus_indexes is part of the [SchemaPlus](https://github.com/SchemaPlus/) family of Ruby on Rails extension gems.

## Installation

In your application's Gemfile

```ruby
gem "schema_plus_indexes"
```
## Compatibility

schema_plus_indexes is tested on

<!-- SCHEMA_DEV: MATRIX - begin -->
<!-- These lines are auto-generated by schema_dev based on schema_dev.yml -->
* ruby **2.1.5** with activerecord **4.2**, using **mysql2**, **sqlite3** or **postgresql**

<!-- SCHEMA_DEV: MATRIX - end -->

## History

### v0.1.0

* Initial release

## Development & Testing

Are you interested in contributing to schema_plus_indexes?  Thanks!  Please follow
the standard protocol: fork, feature branch, develop, push, and issue pull request.

Some things to know about to help you develop and test:

* **schema_dev**:  schema_plus_indexes uses [schema_dev](https://github.com/SchemaPlus/schema_dev) to
  facilitate running rspec tests on the matrix of ruby, rails, and database
  versions that the gem supports, both locally and on
  [travis-ci](http://travis-ci.org/SchemaPlus/schema_plus_indexes)

  To to run rspec locally on the full matrix, do:

        $ schema_dev bundle install
        $ schema_dev rspec

  You can also run on just one configuration at a time;  For info, see `schema_dev --help` or the
  [schema_dev](https://github.com/SchemaPlus/schema_dev) README.

  The matrix of configurations is specified in `schema_dev.yml` in
  the project root.

* **schema_monkey**: schema_plus_indexes extends ActiveRecord using
  [schema_monkey](https://github.com/SchemaPlus/schema_monkey)'s extension
  API and protocols -- see its README for details.  If your contribution needs any additional monkey patching
  that isn't already supported by
  [schema_monkey](https://github.com/SchemaPlus/schema_monkey), please head
  over there and submit a PR.
