class InitialMigration < ActiveRecord::Migration
  def self.up
    create_table "middlewares", :force => true do |t|
      t.string   "name",                                                 :null => false
      t.string   "about_format",   :limit => 10,  :default => "textile", :null => false
      t.text     "about_source",                                         :null => false
      t.text     "about",                                                :null => false
      t.string   "details_format", :limit => 10,  :default => "textile", :null => false
      t.text     "details_source"
      t.text     "details"
      t.string   "usage_format",   :limit => 10,  :default => "textile", :null => false
      t.text     "usage_source",                                         :null => false
      t.text     "usage",                                                :null => false
      t.integer  "user_id",                                              :null => false
      t.integer  "gist_id"
      t.string   "project_page",   :limit => 200
      t.string   "gem_name",       :limit => 50
      t.boolean  "tweeted",                       :default => false,     :null => false
      t.boolean  "finalist",                      :default => false,     :null => false
      t.float    "average_score",                 :default => 0.0,       :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "contest_place"
    end

    add_index "middlewares", ["average_score"], :name => "index_middlewares_on_average_score"
    add_index "middlewares", ["contest_place"], :name => "index_middlewares_on_contest_place"
    add_index "middlewares", ["finalist"], :name => "index_middlewares_on_finalist"
    add_index "middlewares", ["tweeted"], :name => "index_middlewares_on_tweeted"
    add_index "middlewares", ["user_id"], :name => "index_middlewares_on_user_id"

    create_table "middlewares_tags", :id => false, :force => true do |t|
      t.integer "middleware_id", :null => false
      t.integer "tag_id",        :null => false
    end

    add_index "middlewares_tags", ["middleware_id"], :name => "index_middlewares_tags_on_middleware_id"
    add_index "middlewares_tags", ["tag_id"], :name => "index_middlewares_tags_on_tag_id"

    create_table "tags", :force => true do |t|
      t.string "name", :limit => 30, :null => false
    end

    add_index "tags", ["name"], :name => "index_tags_on_name"

    create_table "users", :force => true do |t|
      t.string  "name",             :limit => 30,                    :null => false
      t.string  "email",                                             :null => false
      t.string  "identity_url",                                      :null => false
      t.boolean "admin",                          :default => false, :null => false
      t.string  "github_username",  :limit => 50
      t.string  "twitter_username", :limit => 50
    end

    add_index "users", ["identity_url"], :name => "index_users_on_identity_url"

    create_table "voters", :force => true do |t|
      t.string   "address",    :limit => 16, :null => false
      t.datetime "created_at"
    end

    create_table "votes", :force => true do |t|
      t.integer "middleware_id", :null => false
      t.integer "score",         :null => false
      t.integer "voter_id",      :null => false
    end

    add_index "votes", ["middleware_id", "voter_id"], :name => "index_votes_on_middleware_id_and_voter_id"
  end

  def self.down
    drop_table "middlewares_tags"
    drop_table "middlewares"
    drop_table "tags"
    drop_table "users"
    drop_table "voters"
    drop_table "votes"
  end
end
