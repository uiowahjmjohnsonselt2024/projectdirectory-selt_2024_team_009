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

ActiveRecord::Schema[7.2].define(version: 2024_12_15_070744) do
  create_table "contents", force: :cascade do |t|
    t.text "story_text"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "games", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "server_id", null: false
    t.string "winner"
    t.index ["server_id"], name: "index_games_on_server_id"
  end

  create_table "grid_cells", force: :cascade do |t|
    t.integer "server_id", null: false
    t.integer "x"
    t.integer "y"
    t.integer "content_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "owner_id"
    t.boolean "obstacle", default: false
    t.integer "fortified"
    t.index ["server_id", "x", "y"], name: "index_grid_cells_on_server_id_and_x_and_y", unique: true
  end

  create_table "inventories", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "item_id", null: false
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "item_name"
  end

  create_table "items", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.decimal "price", precision: 10, scale: 2
    t.string "category"
    t.integer "required_level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_url"
  end

  create_table "leaderboard_entries", force: :cascade do |t|
    t.integer "leaderboard_id", null: false
    t.integer "user_id", null: false
    t.integer "points"
    t.integer "rank"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "remaining_ap", default: 0
    t.integer "cells_occupied", default: 0
  end

  create_table "leaderboards", force: :cascade do |t|
    t.string "name"
    t.string "scope"
    t.integer "server_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "game_id"
  end

  create_table "scores", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "server_id", null: false
    t.integer "points"
    t.integer "level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "server_user_items", force: :cascade do |t|
    t.integer "server_user_id", null: false
    t.integer "item_id", null: false
    t.boolean "used", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_server_user_items_on_item_id"
    t.index ["server_user_id"], name: "index_server_user_items_on_server_user_id"
  end

  create_table "server_users", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "server_id", null: false
    t.integer "current_position_x"
    t.integer "current_position_y"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_ap", default: 200
    t.integer "turn_ap", default: 2
    t.integer "shard_balance", default: 0
    t.string "symbol"
    t.integer "turn_order"
    t.boolean "can_move_diagonally"
    t.integer "diagonal_moves_left"
    t.boolean "mirror_shield"
    t.integer "turns_skipped"
    t.string "cable_token"
    t.integer "role", null: false
    t.index ["role"], name: "index_server_users_on_role"
  end

  create_table "servers", force: :cascade do |t|
    t.string "name"
    t.integer "max_players"
    t.integer "created_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "pending"
    t.integer "current_turn_server_user_id"
    t.string "background_image_url"
    t.string "role"
    t.integer "turn_count"
    t.index ["created_by"], name: "index_servers_on_created_by"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "transaction_type"
    t.decimal "amount", precision: 10, scale: 2
    t.string "currency"
    t.string "payment_method"
    t.integer "item_id"
    t.integer "quantity"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "treasure_finds", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "treasure_id", null: false
    t.integer "server_id", null: false
    t.datetime "found_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "treasures", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "points"
    t.integer "item_id", null: false
    t.string "unlock_criteria"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "game_id", null: false
    t.integer "grid_cell_id", null: false
    t.integer "owner_id"
    t.index ["game_id"], name: "index_treasures_on_game_id"
    t.index ["grid_cell_id"], name: "index_treasures_on_grid_cell_id"
    t.index ["owner_id"], name: "index_treasures_on_owner_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "role", default: "player", null: false
    t.string "cable_token"
    t.index ["cable_token"], name: "index_users_on_cable_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "wallets", force: :cascade do |t|
    t.integer "user_id", null: false
    t.decimal "balance", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "games", "servers"
  add_foreign_key "grid_cells", "contents"
  add_foreign_key "grid_cells", "servers"
  add_foreign_key "inventories", "items"
  add_foreign_key "inventories", "users"
  add_foreign_key "leaderboard_entries", "leaderboards"
  add_foreign_key "leaderboard_entries", "users"
  add_foreign_key "leaderboards", "servers"
  add_foreign_key "scores", "servers"
  add_foreign_key "scores", "users"
  add_foreign_key "server_user_items", "items"
  add_foreign_key "server_user_items", "server_users"
  add_foreign_key "server_users", "servers"
  add_foreign_key "server_users", "users"
  add_foreign_key "servers", "users", column: "created_by"
  add_foreign_key "transactions", "items"
  add_foreign_key "transactions", "users"
  add_foreign_key "treasure_finds", "servers"
  add_foreign_key "treasure_finds", "treasures"
  add_foreign_key "treasure_finds", "users"
  add_foreign_key "treasures", "games"
  add_foreign_key "treasures", "grid_cells"
  add_foreign_key "treasures", "items"
  add_foreign_key "treasures", "server_users", column: "owner_id"
  add_foreign_key "wallets", "users"
end
