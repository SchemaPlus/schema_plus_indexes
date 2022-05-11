# frozen_string_literal: true

require 'spec_helper'

describe "index" do

  let(:migration) { ::ActiveRecord::Migration }
  let(:connection) { ::ActiveRecord::Base.connection }

  describe "add_index" do

    before(:each) do
      each_table connection do |table| connection.drop_table table, cascade: true end

      define_schema(auto_create: false) do
        create_table :users, force: true do |t|
          t.string :login
          t.text :address
          t.datetime :deleted_at
        end

        create_table :posts, force: true do |t|
          t.text :body
          t.integer :user_id
          t.integer :author_id
        end

      end
      class User < ::ActiveRecord::Base ; end
      class Post < ::ActiveRecord::Base ; end
    end


    after(:each) do
      migration.remove_index(:users, name: @index.name) if (@index ||= nil)
    end

    it "should create index when called without additional options" do
      add_index(:users, :login)
      expect(index_for(:login)).not_to be_nil
    end

    it "should create unique index" do
      add_index(:users, :login, unique: true)
      expect(index_for(:login).unique).to eq(true)
    end

    it "should assign given name" do
      add_index(:users, :login, name: 'users_login_index')
      expect(index_for(:login).name).to eq('users_login_index')
    end

    it "should assign order", mysql: :skip do
      add_index(:users, [:login, :deleted_at], order: {login: :desc, deleted_at: :asc})
      expect(index_for([:login, :deleted_at]).orders).to eq({"login" => :desc, "deleted_at" => :asc})
    end

    it "should assign order (all same direction)", mysql: :skip do
      add_index(:users, [:login, :deleted_at], order: {login: :desc, deleted_at: :desc})
      expect(index_for([:login, :deleted_at]).orders).to eq({"login" => :desc, "deleted_at" => :desc})
    end

    context "for duplicate index", rails: '< 6.1' do
      it "should not complain if the index is the same" do
        add_index(:users, :login)
        expect(index_for(:login)).not_to be_nil
        expect(ActiveRecord::Base.logger).to receive(:warn).with(/login.*Skipping/)
        expect { add_index(:users, :login) }.to_not raise_error
        expect(index_for(:login)).not_to be_nil
      end
      it "should complain if the index is different" do
        add_index(:users, :login, unique: true)
        expect(index_for(:login)).not_to be_nil
        expect { add_index(:users, :login) }.to raise_error(ArgumentError, /already exists/)
        expect(index_for(:login)).not_to be_nil
      end
    end

    context "for duplicate index", rails: '>= 6.1' do
      it "should raise a statement invalid if the index is the same", postgresql: :skip do
        add_index(:users, :login)
        expect(index_for(:login)).not_to be_nil
        expect { add_index(:users, :login) }.to raise_error(ActiveRecord::StatementInvalid)
        expect(index_for(:login)).not_to be_nil
      end
      it "should raises a statement invalid if the index is different" do
        add_index(:users, :login, unique: true)
        expect(index_for(:login)).not_to be_nil
        expect { add_index(:users, :login) }.to raise_error(ActiveRecord::StatementInvalid)
        expect(index_for(:login)).not_to be_nil
      end
      context 'when if_not_exists is passed' do
        it "should not raise an error if the index is the same" do
          add_index(:users, :login)
          expect(index_for(:login)).not_to be_nil
          expect { add_index(:users, :login, if_not_exists: true) }.to_not raise_error
          expect(index_for(:login)).not_to be_nil
        end

        it "should raise an error if the index is different" do
          add_index(:users, :login, unique: true)
          expect(index_for(:login)).not_to be_nil
          expect { add_index(:users, :login) }.to raise_error(ActiveRecord::StatementInvalid)
          expect(index_for(:login)).not_to be_nil
        end
      end
    end

    protected

    def index_for(column_names)
      @index = User.indexes.detect { |i| i.columns == Array(column_names).collect(&:to_s) }
    end

  end

  describe "remove_index" do

    before(:each) do
      each_table connection do |table| connection.drop_table table, cascade: true end
      define_schema(auto_create: false) do
        create_table :users, force: true do |t|
          t.string :login
          t.datetime :deleted_at
        end
      end
      class User < ::ActiveRecord::Base ; end
    end


    it "removes index by column name (symbols)" do
      add_index :users, :login
      expect(User.indexes.length).to eq(1)
      remove_index :users, :login
      expect(User.indexes.length).to eq(0)
    end

    it "removes index by column name (symbols)" do
      add_index :users, :login
      expect(User.indexes.length).to eq(1)
      remove_index 'users', 'login'
      expect(User.indexes.length).to eq(0)
    end

    it "removes multi-column index by column names (symbols)" do
      add_index :users, [:login, :deleted_at]
      expect(User.indexes.length).to eq(1)
      remove_index :users, [:login, :deleted_at]
      expect(User.indexes.length).to eq(0)
    end

    it "removes multi-column index by column names (strings)" do
      add_index 'users', [:login, :deleted_at]
      expect(User.indexes.length).to eq(1)
      remove_index 'users', ['login', 'deleted_at']
      expect(User.indexes.length).to eq(0)
    end

    it "removes index using column option" do
      add_index :users, :login
      expect(User.indexes.length).to eq(1)
      remove_index :users, column: :login
      expect(User.indexes.length).to eq(0)
    end

    it "removes index if_exists" do
      add_index :users, :login
      expect(User.indexes.length).to eq(1)
      remove_index :users, :login, if_exists: true
      expect(User.indexes.length).to eq(0)
    end

    it "removes multi-column index if exists" do
      add_index :users, [:login, :deleted_at]
      expect(User.indexes.length).to eq(1)
      remove_index :users, [:login, :deleted_at], if_exists: true
      expect(User.indexes.length).to eq(0)
    end

    it "removes index if_exists using column option" do
      add_index :users, :login
      expect(User.indexes.length).to eq(1)
      remove_index :users, column: :login, if_exists: true
      expect(User.indexes.length).to eq(0)
    end

    it "raises exception if doesn't exist" do
      expect {
        remove_index :users, :login
      }.to raise_error(ArgumentError)
    end

    it "doesn't raise exception with :if_exists" do
      expect {
        remove_index :users, :login, if_exists: true
      }.to_not raise_error
    end
  end

  protected
  def add_index(*args, **kwargs)
    migration.add_index(*args, **kwargs)
    User.reset_column_information
  end

  def remove_index(*args, **kwargs)
    migration.remove_index(*args, **kwargs)
    User.reset_column_information
  end

end
