# frozen_string_literal: true

require 'spec_helper'


describe "Index definition" do

  let(:migration) { ::ActiveRecord::Migration }

  before(:each) do
    define_schema(:auto_create => false) do
      create_table :users, :force => true do |t|
        t.string :login
        t.datetime :deleted_at
      end

      create_table :posts, :force => true do |t|
        t.text :body
        t.integer :user_id
        t.integer :author_id
      end

    end
    class User < ::ActiveRecord::Base ; end
    class Post < ::ActiveRecord::Base ; end
  end

  after(:each) do
    migration.remove_index :users, :name => 'users_login_index' if migration.index_name_exists?(:users, 'users_login_index')
  end

  context "when index is multicolumn" do
    before(:each) do
      migration.execute "CREATE INDEX users_login_index ON users (login, deleted_at)"
      User.reset_column_information
      @index = index_definition(%w[login deleted_at])
    end

    it "is included in User.indexes" do
      expect(@index).not_to be_nil
    end

  end

  it "should not crash on equality test with nil" do
    index = ActiveRecord::ConnectionAdapters::IndexDefinition.new(:table, :column)
    expect{index == nil}.to_not raise_error
    expect(index == nil).to be false
  end


  context "when index is ordered", :mysql => :skip do

    quotes = [
      ["unquoted", ''],
      ["double-quoted", '"'],
    ]
    quotes += [
      ["single-quoted", "'"],
      ["back-quoted", '`']
    ] if SchemaDev::Rspec::Helpers.sqlite3?

    quotes.each do |quotename, quote|
      it "index definition includes orders for #{quotename} columns" do
        migration.execute "CREATE INDEX users_login_index ON users (#{quote}login#{quote} DESC, #{quote}deleted_at#{quote} ASC)"
        User.reset_column_information
        index = index_definition(%w[login deleted_at])
        expect(index.orders).to eq({"login" => :desc, "deleted_at" => :asc})
      end

    end
  end

  context "when index is partial" do
    before(:each) do
      migration.execute "CREATE INDEX users_login_index ON users(login) WHERE deleted_at IS NULL"
      User.reset_column_information
      @index = index_definition("login")
    end

    it "is included in User.indexes" do
      expect(User.indexes.select { |index| index.columns == ["login"] }.size).to eq(1)
    end

    it "defines where" do
      expect(@index.where).to match %r{[(]?deleted_at IS NULL[)]?}
    end

  end if ::ActiveRecord::Migration.supports_partial_index?


  protected
  def index_definition(column_names)
    User.indexes.detect { |index| index.columns == Array(column_names) }
  end


end
