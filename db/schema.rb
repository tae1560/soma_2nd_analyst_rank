# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130315015116) do

  create_table "day_candles", :force => true do |t|
    t.string   "symbol"
    t.datetime "trading_date"
    t.integer  "open"
    t.integer  "high"
    t.integer  "low"
    t.integer  "close"
    t.integer  "volume"
    t.integer  "stock_code_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "day_candles", ["symbol", "trading_date"], :name => "index_day_candles_on_symbol_and_trading_date", :unique => true

  create_table "raw_day_candles", :force => true do |t|
    t.datetime "date"
    t.integer  "o"
    t.integer  "h"
    t.integer  "l"
    t.integer  "c"
    t.integer  "v"
    t.string   "symbol"
    t.integer  "day_candle_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "raw_day_candles", ["symbol", "date"], :name => "index_raw_day_candles_on_symbol_and_date", :unique => true

  create_table "raw_recommendations", :force => true do |t|
    t.string   "in_dt"
    t.string   "cmp_nm_kor"
    t.string   "cmp_cd"
    t.string   "brk_nm_kor"
    t.integer  "brk_cd"
    t.string   "pf_nm_kor"
    t.integer  "pf_cd"
    t.string   "recomm_price"
    t.string   "recomm_rate"
    t.integer  "recommend_adj_price"
    t.integer  "pre_adj_price"
    t.string   "pre_dt"
    t.integer  "cnt"
    t.string   "reason_in"
    t.string   "file_nm"
    t.string   "anl_dt"
    t.string   "in_diff_reason"
    t.integer  "recommendation_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "raw_recommendations", ["cmp_cd", "brk_cd", "pf_cd"], :name => "index_raw_recommendations_on_cmp_cd_and_brk_cd_and_pf_cd", :unique => true

  create_table "raw_stock_codes", :force => true do |t|
    t.string   "institution_code"
    t.string   "name"
    t.string   "eng_name"
    t.string   "standard_code"
    t.string   "short_code"
    t.string   "market_type"
    t.integer  "stock_code_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "recommendations", :force => true do |t|
    t.datetime "in_date"
    t.string   "symbol"
    t.integer  "stock_code_id"
    t.integer  "day_candle_id"
    t.integer  "stock_firm_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "stock_codes", :force => true do |t|
    t.string   "name"
    t.string   "eng_name"
    t.string   "symbol"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "stock_firms", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.float    "profit_recent"
    t.float    "profit_1_month"
    t.float    "profit_2_month"
    t.float    "profit_3_month"
    t.float    "profit_4_month"
    t.float    "profit_5_month"
    t.float    "profit_6_month"
    t.float    "profit_7_month"
    t.float    "profit_8_month"
    t.float    "profit_9_month"
    t.float    "profit_10_month"
    t.float    "profit_11_month"
    t.float    "profit_12_month"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                :default => "", :null => false
    t.string   "encrypted_password",                   :default => ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.string   "name"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "invitation_token",       :limit => 60
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["invitation_token"], :name => "index_users_on_invitation_token"
  add_index "users", ["invited_by_id"], :name => "index_users_on_invited_by_id"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

end
