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

ActiveRecord::Schema.define(version: 20140306220907) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "coauthorships", force: true do |t|
    t.integer "author_id",   null: false
    t.integer "coauthor_id", null: false
  end

  add_index "coauthorships", ["author_id", "coauthor_id"], name: "index_coauthorships_on_author_id_and_coauthor_id", unique: true, using: :btree
  add_index "coauthorships", ["author_id"], name: "index_coauthorships_on_author_id", using: :btree

  create_table "contributors", force: true do |t|
    t.string  "surname"
    t.string  "given_name"
    t.string  "role"
    t.string  "primary_unit"
    t.integer "person_id"
    t.string  "title"
    t.string  "name_slug"
    t.string  "primary_unit_slug"
  end

  add_index "contributors", ["name_slug"], name: "index_contributors_on_name_slug", using: :btree
  add_index "contributors", ["person_id"], name: "index_contributors_on_person_id", unique: true, using: :btree
  add_index "contributors", ["primary_unit"], name: "index_contributors_on_primary_unit", using: :btree
  add_index "contributors", ["primary_unit_slug"], name: "index_contributors_on_primary_unit_slug", using: :btree
  add_index "contributors", ["surname"], name: "index_contributors_on_surname", using: :btree

  create_table "topics", force: true do |t|
    t.string  "name"
    t.string  "slug"
    t.integer "record_count"
    t.string  "lcsh"
  end

  add_index "topics", ["record_count"], name: "index_topics_on_record_count", using: :btree
  add_index "topics", ["slug"], name: "index_topics_on_slug", unique: true, using: :btree

end
