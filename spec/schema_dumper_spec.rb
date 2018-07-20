require 'spec_helper'
require 'stringio'

describe "Schema dump" do

  before(:each) do
    define_schema do

      create_table :users, :force => true do |t|
        t.string :login
        t.datetime :deleted_at
        t.integer :first_post_id
      end

      create_table :posts, :force => true do |t|
        t.text :body
        t.integer :user_id
        t.integer :first_comment_id
        t.string :string_no_default
        t.integer :short_id
        t.string :str_short
        t.integer :integer_col
        t.float :float_col
        t.decimal :decimal_col
        t.datetime :datetime_col
        t.timestamp :timestamp_col
        t.time :time_col
        t.date :date_col
        t.binary :binary_col
        t.boolean :boolean_col
      end

      create_table :comments, :force => true do |t|
        t.text :body
        t.integer :post_id
        t.integer :commenter_id
      end
    end
    class ::User < ActiveRecord::Base ; end
    class ::Post < ActiveRecord::Base ; end
    class ::Comment < ActiveRecord::Base ; end
  end

  it "should include in-table index definition" do
    with_index Post, :user_id do
      expect(dump_posts).to match(/"user_id",.*:index=>/)
    end
  end

  it "should not include add_index statement" do
    with_index Post, :user_id do
      expect(dump_posts).not_to match(%r{add_index.*user_id})
    end
  end

  it "should include index name" do
    with_index Post, :user_id, :name => "custom_name" do
      expect(dump_posts).to match(/"user_id",.*:index=>.*:name=>"custom_name"/)
    end
  end

  it "should define unique index" do
    with_index Post, :user_id, :name => "posts_user_id_index", :unique => true do
      expect(dump_posts).to match(/"user_id",.*:index=>.*:name=>"posts_user_id_index", :unique=>true/)
    end
  end

  it "should include index order", :mysql => :skip do
    with_index Post, [:user_id, :first_comment_id, :short_id], :order => { :user_id => :asc, :first_comment_id => :desc } do
      # allow :order hash to key on strings (AR 5.0) or symbols (AR 5.1)
      expect(dump_posts).to match(/"user_id".*:index=>{.*:with=>\["first_comment_id", "short_id"\],.*:order=>{[:"]first_comment_id"?=>:desc, [:"]user_id"?=>:asc, [:"]short_id"?=>:asc}/)
    end
  end

  protected

  def to_regexp(string)
    Regexp.new(Regexp.escape(string))
  end

  def with_index(*args)
    options = args.extract_options!
    model, columns = args
    ActiveRecord::Migration.add_index(model.table_name, columns, options)
    model.reset_column_information
    begin
      yield
    ensure
      ActiveRecord::Migration.remove_index(model.table_name, :name => determine_index_name(model, columns, options))
    end
  end

  def determine_index_name(model, columns, options)
    name = columns[:name] if columns.is_a?(Hash)
    name ||= options[:name]
    name ||= model.indexes.detect { |index| index.table == model.table_name.to_s && index.columns.sort == Array(columns).collect(&:to_s).sort }.name
    name
  end

  def dump_schema(opts={})
    stream = StringIO.new
    ActiveRecord::SchemaDumper.ignore_tables = Array.wrap(opts[:ignore]) || []
    ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, stream)
    stream.string
  end

  def dump_posts
    dump_schema(:ignore => %w[users comments])
  end

end

