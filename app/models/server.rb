class Server < ApplicationRecord
  require 'openai'

  # Associations
  has_many :server_users, dependent: :destroy
  has_many :grid_cells, dependent: :destroy
  has_many :users, through: :server_users
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by'
  belongs_to :current_turn_server_user, class_name: 'ServerUser', optional: true

  # Validations
  validates :status, inclusion: { in: %w[pending in_progress finished] }
  validates :max_players, numericality: { only_integer: true, greater_than_or_equal_to: 2, less_than_or_equal_to: 6 }
  after_create :add_creator_as_server_user

  # Callbacks
  # Start the game and generate the game board background image
  def start_game
    user_names = server_users.includes(:user).map { |su| su.user.username }
    Rails.logger.info "Starting game on server_model, startgame #{id} with users: #{user_names.join(', ')}"

    # Ensure the creator is added as a player
    server_users.find_or_create_by(user: creator)

    # Generate the game board background image
    generate_game_board_image

    # Initialize the game board grid
    initialize_grid

    # Assign symbols and turn order
    assign_symbols_and_turn_order

    # Assign starting positions for players
    assign_starting_positions

    # Mark game as in progress
    update!(status: 'in_progress', current_turn_server_user: server_users.order(:turn_order).first)
  end

  # Generate the game board image
  def generate_game_board_image
    # Skip if image already exists
    return if background_image_url.present?
    # prompt = "A beautiful 6x6 game grid with a strategic design in pixel art style"
    prompt = "A top-down view of a 6x6 game grid, pixel art style, colorful and vibrant"
    client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

    begin
      # Generate the image with correct DALL-E 3 size
      response = client.images.generate(
        parameters: {
          prompt: prompt,
          model: "dall-e-3",
          size: "1024x1024",  # DALL-E 3 supports 1024x1024, 1792x1024, or 1024x1792
          n: 1
        }
      )

      # Save the image URL if successful
      if response.dig("data", 0, "url").present?
        update!(background_image_url: response["data"][0]["url"])
        Rails.logger.info "Generated game board image for server #{id}"
      else
        Rails.logger.error "Failed to get image URL for server #{id}"
        set_default_game_board_image
      end

    rescue => e
      Rails.logger.error "Error generating image: #{e.message}"
      set_default_game_board_image
    end
  end

  def set_default_game_board_image
    update!(background_image_url: "/assets/images/game_background.png")
    Rails.logger.info "Default game board image set for server #{id}: #{background_image_url}"
  end

  # Initialize the game board grid
  def initialize_grid
    (0..5).each do |x|
      (0..5).each do |y|
        grid_cells.create!(x: x, y: y)
      end
    end

    place_treasures
    place_obstacles
  end

  # Place treasures on the grid
  def place_treasures
    treasure_cells = grid_cells.sample(5)
    treasure_cells.each do |cell|
      cell.update!(treasure: Treasure.all.sample)
    end
  end

  # Place obstacles on the grid
  def place_obstacles
    obstacle_cells = grid_cells.where(treasure: nil).sample(5)
    obstacle_cells.each do |cell|
      cell.update!(obstacle: true)
    end
  end

  # Assign symbols to players and determine turn order
  def assign_symbols_and_turn_order
    symbols = %w[🟢 🔴 🔵 🟡 🟣 🟤].freeze
    assigned_symbols = server_users.pluck(:symbol).compact
    available_symbols = symbols - assigned_symbols
    server_users.each_with_index do |server_user, index|
      next if server_user.symbol.present?

      server_user.update(
        symbol: available_symbols.shift,
        turn_order: index + 1
      )
    end
  end

  # Assign starting positions for players
  def assign_starting_positions(new_user: nil)
    available_cells = grid_cells.where(obstacle: false, owner: nil).to_a
    Rails.logger.info "Available cells for assignment: #{available_cells.map { |cell| [cell.x, cell.y] }}"

    users_to_assign = new_user ? [new_user] : server_users

    users_to_assign.each do |server_user|
      # Ensure the server_user is persisted with a valid cable_token
      if !server_user.persisted? || server_user.cable_token.blank?
        Rails.logger.error "ServerUser #{server_user.user.username} has invalid or duplicate cable_token."
        next
      end

      next if server_user.current_position_x && server_user.current_position_y

      # Assign a valid starting cell
      starting_cell = find_valid_starting_cell(available_cells, server_user)
      assign_cell_to_user(starting_cell, server_user)
      available_cells.delete(starting_cell)
    end
  end



  # Find a valid starting cell for a player
  def find_valid_starting_cell(available_cells, server_user)
    attempts = 0
    while attempts < 100
      cell = available_cells.sample
      return cell if valid_starting_position?(cell, server_user)

      attempts += 1
    end
    raise "Unable to find a valid starting position for #{server_user.user.username}"
  end

  # Assign a cell to a user
  def assign_cell_to_user(cell, server_user)
    unless server_user.persisted?
      Rails.logger.error "Cannot assign cell to non-persisted ServerUser #{server_user.inspect}"
      raise ActiveRecordError, "ServerUser must be persisted before assigning a cell"
    end

    Rails.logger.info "Assigning cell [#{cell.x}, #{cell.y}] to ServerUser #{server_user.id} (persisted? #{server_user.persisted?})"

    # Update the grid cell
    cell.update!(owner: server_user)

    # Explicitly update only the position attributes
    server_user.update!(
      current_position_x: cell.x,
      current_position_y: cell.y
    )
  end



  private

  # Check if a cell is a valid starting position
  def valid_starting_position?(cell, server_user)
    other_positions = server_users.where.not(id: server_user.id).pluck(:current_position_x, :current_position_y)
    other_positions.all? do |x, y|
      [(cell.x - x).abs, (cell.y - y).abs].max >= 2 && !cell.obstacle?
    end
  end
  def validate_server_users_presence
    errors.add(:base, "Server must have at least one server user") if server_users.empty?
    # Add any other custom validations here
  end
  # Ensure the creator is a ServerUser

  def add_creator_as_server_user
    server_users.create!(
      user: creator,
      role: 'player',
      cable_token: creator.cable_token,
      turn_order: 1,
      symbol: '🟢'
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to add creator as ServerUser: #{e.message}"
    raise
  end
end