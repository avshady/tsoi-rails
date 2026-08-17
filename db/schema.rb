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

ActiveRecord::Schema[8.1].define(version: 2026_08_03_000001) do
  create_table "inquiries", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.text "message"
    t.string "name"
    t.string "phone"
    t.string "school_name"
    t.string "service"
    t.string "status"
    t.datetime "updated_at", null: false
  end

  create_table "posts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "author"
    t.text "body"
    t.string "category"
    t.string "cover_image"
    t.datetime "created_at", null: false
    t.text "excerpt"
    t.boolean "published", default: false, null: false
    t.datetime "published_at"
    t.string "slug", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["published", "published_at"], name: "index_posts_on_published_and_published_at"
    t.index ["slug"], name: "index_posts_on_slug", unique: true
  end

  create_table "schools", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "address"
    t.text "admission_criteria"
    t.string "admission_deadline", limit: 100
    t.integer "admission_fee"
    t.integer "admission_open", limit: 1, default: 0
    t.string "admission_start", limit: 100
    t.string "admission_test_date", limit: 100
    t.string "affiliation_no", limit: 100
    t.integer "annual_fees_max"
    t.integer "annual_fees_min"
    t.string "board", limit: 100, null: false
    t.string "city", limit: 100, null: false
    t.timestamp "created_at", default: -> { "CURRENT_TIMESTAMP" }
    t.text "description"
    t.string "district", limit: 100
    t.string "email", limit: 100
    t.integer "established"
    t.text "facilities"
    t.text "gallery_images"
    t.string "gender", limit: 50, default: "Co-Ed", null: false
    t.string "grades", limit: 100, null: false
    t.text "hall_of_fame"
    t.text "image_url"
    t.text "insights"
    t.integer "is_featured", limit: 1, default: 0
    t.string "name", null: false
    t.float "pass_percentage"
    t.string "phone", limit: 50
    t.string "portal_email", limit: 150
    t.string "portal_token", limit: 64
    t.float "rating", default: 0.0
    t.integer "security_deposit"
    t.string "state", limit: 100, null: false
    t.string "student_teacher_ratio", limit: 50
    t.float "top_scorers_pct"
    t.integer "total_reviews", default: 0
    t.string "type", limit: 50, null: false
    t.text "video_urls"
    t.text "virtual_tour_url"
    t.string "website", limit: 500
    t.index ["annual_fees_max"], name: "idx_fees_max"
    t.index ["annual_fees_min"], name: "idx_fees_min"
    t.index ["board"], name: "idx_board"
    t.index ["city"], name: "idx_city", length: 50
    t.index ["district"], name: "idx_district"
    t.index ["gender"], name: "idx_gender", length: 20
    t.index ["is_featured", "rating", "name"], name: "idx_sort", length: { name: 40 }
    t.index ["is_featured"], name: "idx_featured"
    t.index ["name", "city", "description"], name: "ft_search", type: :fulltext
    t.index ["portal_token"], name: "idx_portal_token", unique: true
    t.index ["rating"], name: "idx_rating"
    t.index ["state"], name: "idx_state"
    t.index ["type"], name: "idx_type"
  end

  create_table "site_content", primary_key: "key", id: { type: :string, limit: 100 }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.timestamp "updated_at", default: -> { "CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" }
    t.text "value", size: :long, null: false
  end

  create_table "summit_speakers", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "accent_color", default: "#ff2a7f"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "organisation"
    t.string "photo"
    t.integer "position", default: 0
    t.string "title"
    t.datetime "updated_at", null: false
  end
end
