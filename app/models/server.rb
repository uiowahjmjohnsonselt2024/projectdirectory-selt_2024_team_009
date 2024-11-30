class Server < ApplicationRecord
  has_many :server_users, dependent: :destroy
  has_many :grid_cells, dependent: :destroy
  has_many :users, through: :server_users
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by'
  belongs_to :current_turn_server_user, class_name: 'ServerUser', optional: true

  # Validations
  validates :status, inclusion: { in: %w[pending in_progress finished] }

  # Initialize Game
  def start_game
    assign_symbols_and_turn_order
    initialize_grid
    assign_starting_positions
    update(status: 'in_progress', current_turn_server_user: server_users.order(:turn_order).first)
  end
  # For convenience
  def status
    super || 'pending'
  end
  private

  def assign_symbols_and_turn_order
    symbols = ['🟢', '🔴', '🔵', '🟡', '🟣', '🟤'].shuffle
    turn_orders = (1..server_users.count).to_a.shuffle

    server_users.each_with_index do |server_user, index|
      server_user.update(symbol: symbols[index], turn_order: turn_orders[index])
    end
  end

  def initialize_grid
    (0..5).each do |x|
      (0..5).each do |y|
        grid_cells.create(x: x, y: y)
      end
    end

    # Place treasures
    treasure_cells = grid_cells.sample(5)
    treasure_cells.each do |cell|
      cell.update(treasure: Treasure.all.sample)
    end

    # Randomly place obstacles (limit to 5)
    obstacle_cells = grid_cells.where(treasure: nil).sample(5)
    obstacle_cells.each do |cell|
      cell.update(obstacle: true)
    end
  end

  def assign_starting_positions
    available_cells = grid_cells.where(obstacle: false, owner_id: nil).to_a
    server_users.each do |server_user|
      attempts = 0
      loop do
        starting_cell = available_cells.sample
        if valid_starting_position?(starting_cell, server_user)
          server_user.update(current_position_x: starting_cell.x, current_position_y: starting_cell.y)
          break
        end
        attempts += 1
        if attempts > 1000
          raise "Unable to find a valid starting position for #{server_user.user.username}"
        end
      end
    end
  end

  def valid_starting_position?(cell, server_user)
    other_server_users = server_users.where.not(id: server_user.id)
                                     .where.not(current_position_x: nil, current_position_y: nil)

    other_server_users.all? do |other|
      distance = [(cell.x - other.current_position_x).abs, (cell.y - other.current_position_y).abs].max
      distance >= 2
    end
  end

end
