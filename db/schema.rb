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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160621035040) do

  create_table "costs", force: :cascade do |t|
    t.string   "business_type"
    t.string   "payment_type"
    t.decimal  "low_ticket"
    t.decimal  "high_ticket"
    t.decimal  "per_item_value"
    t.decimal  "percentage_value"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "descriptions", force: :cascade do |t|
    t.string   "business_type_primary"
    t.string   "business_type_secondary"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "amex_business_type"
  end

  create_table "merchants", force: :cascade do |t|
    t.string   "business_dba"
    t.integer  "data_number"
    t.string   "business_type_primary"
    t.string   "business_type_secondary"
    t.integer  "sic_1"
    t.integer  "sic_2"
    t.integer  "sic_3"
    t.decimal  "interchange_percentage"
    t.decimal  "avg_ticket"
    t.decimal  "amex_percentage"
    t.decimal  "amex_per_item"
    t.decimal  "check_card_percentage"
    t.decimal  "amex_vol"
    t.decimal  "check_card_vol"
    t.decimal  "mc_vol"
    t.decimal  "vs_vol"
    t.decimal  "disc_vol"
    t.decimal  "debit_vol"
    t.integer  "total_transactions"
    t.integer  "amex_transactions"
    t.decimal  "interchange_fees"
    t.decimal  "total_fees"
    t.integer  "debit_transactions"
    t.decimal  "debit_network_fees"
    t.decimal  "ebt_vol"
    t.decimal  "ebt_fees"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "processors", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "programs", force: :cascade do |t|
    t.integer  "processor_id"
    t.string   "name"
    t.decimal  "min_volume"
    t.decimal  "max_volume"
    t.decimal  "up_front_bonus"
    t.decimal  "residual_split"
    t.decimal  "min_bp_mark_up"
    t.decimal  "min_per_item_fee"
    t.string   "cost_structure"
    t.string   "terminal_type"
    t.string   "terminal_ownership_type"
    t.decimal  "per_item_cost"
    t.decimal  "bin_sponsorship"
    t.decimal  "visa_access_per_item"
    t.decimal  "visa_access_percentage"
    t.decimal  "mc_access_per_item"
    t.decimal  "mc_access_percentage"
    t.decimal  "disc_access_per_item"
    t.decimal  "disc_access_percentage"
    t.decimal  "min_monthly_fees"
    t.decimal  "monthly_fee_costs"
    t.decimal  "monthly_pci_fee"
    t.decimal  "monthly_pci_cost"
    t.decimal  "annual_pci_fee"
    t.decimal  "annual_pci_cost"
    t.decimal  "min_pin_debit_per_item_fee"
    t.decimal  "pin_debit_per_item_cost"
    t.decimal  "monthly_debit_fee_cost"
    t.decimal  "min_monthly_debit_fee"
    t.decimal  "next_day_funding_monthly_cost"
    t.decimal  "next_day_funding_monthly_fee"
    t.decimal  "amex_per_item_cost"
    t.decimal  "min_amex_per_item_fee"
    t.decimal  "amex_bp_cost"
    t.decimal  "min_amex_bp_fee"
    t.decimal  "application_fee_cost"
    t.decimal  "min_application_fee"
    t.decimal  "min_per_batch_fee"
    t.decimal  "per_batch_cost"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "programs", ["processor_id"], name: "index_programs_on_processor_id"

  create_table "prospects", force: :cascade do |t|
    t.string   "business_name"
    t.string   "contact_name"
    t.string   "phone"
    t.string   "email"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "user_id"
    t.integer  "description_id"
    t.string   "description_primary"
    t.string   "description_secondary"
    t.string   "amex_business_type"
    t.string   "source_type"
  end

  add_index "prospects", ["description_id"], name: "index_prospects_on_description_id"
  add_index "prospects", ["user_id"], name: "index_prospects_on_user_id"

  create_table "statements", force: :cascade do |t|
    t.decimal  "total_fees"
    t.integer  "batches"
    t.integer  "amex_trans"
    t.decimal  "amex_vol"
    t.integer  "vmd_trans"
    t.decimal  "vmd_vol"
    t.integer  "debit_trans"
    t.decimal  "debit_vol"
    t.decimal  "interchange"
    t.string   "statement_month"
    t.decimal  "avg_ticket"
    t.decimal  "vmd_avg_ticket"
    t.decimal  "amex_avg_ticket"
    t.decimal  "debit_avg_ticket"
    t.decimal  "check_card_avg_ticket"
    t.decimal  "check_card_trans"
    t.decimal  "check_card_vol"
    t.decimal  "debit_network_fees"
    t.decimal  "check_card_interchange"
    t.decimal  "amex_interchange"
    t.decimal  "vmd_interchange"
    t.decimal  "total_vol"
    t.string   "business_type"
    t.integer  "prospect_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "subscribed"
    t.string   "stripeid"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
