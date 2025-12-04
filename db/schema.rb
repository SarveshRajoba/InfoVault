# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_12_04_170221) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "answers", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.text "answer", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_answers_on_question_id"
  end

  create_table "chapters", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "subject_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subject_id"], name: "index_chapters_on_subject_id"
  end

  create_table "collaborations", force: :cascade do |t|
    t.bigint "subject_id", null: false
    t.bigint "user_id", null: false
    t.bigint "owner_id", null: false
    t.string "status", null: false
    t.string "access_level", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subject_id"], name: "index_collaborations_on_subject_id"
    t.index ["user_id"], name: "index_collaborations_on_user_id"
  end

  create_table "paragraphs", force: :cascade do |t|
    t.bigint "chapter_id", null: false
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "num_questions", default: 5, null: false
    t.index ["chapter_id"], name: "index_paragraphs_on_chapter_id"
    t.index ["user_id"], name: "index_paragraphs_on_user_id"
  end

  create_table "questions", force: :cascade do |t|
    t.bigint "paragraph_id", null: false
    t.text "question", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["paragraph_id"], name: "index_questions_on_paragraph_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_subjects_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", default: "user", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "answers", "questions"
  add_foreign_key "chapters", "subjects"
  add_foreign_key "collaborations", "subjects"
  add_foreign_key "collaborations", "users"
  add_foreign_key "paragraphs", "chapters"
  add_foreign_key "paragraphs", "users"
  add_foreign_key "questions", "paragraphs"
  add_foreign_key "subjects", "users"
end
