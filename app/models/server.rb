class Server < ApplicationRecord
  has_many :server_users, dependent: :destroy
  has_many :grid_cells, dependent: :destroy
  has_many :users, through: :server_users
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by'
  belongs_to :current_turn_server_user, class_name: 'ServerUser', optional: true

  # Validations
  validates :status, inclusion: { in: %w[pending in_progress finished] }

  def assign_symbols_and_turn_order
    symbols = %w[🟢 🔴 🔵 🟡 🟣 🟤].freeze
    assigned_symbols = server_users.pluck(:symbol).compact # Get already assigned symbols
    available_symbols = symbols - assigned_symbols        # Determine unassigned symbols

    server_users.each_with_index do |server_user, index|
      next if server_user.symbol.present? # Skip if symbol already assigned

      server_user.update(
        symbol: available_symbols.shift, # Assign the first available symbol
        turn_order: server_users.count   # Assign turn order based on count
      )
    end
  end

  # Initialize Game
  # Start game initialization
  def start_game
    unless server_users.exists?(user: creator)
      server_users.create(user: creator)
    end
    assign_symbols_and_turn_order
    initialize_grid
    assign_starting_positions   # Ensure this is called to assign positions before starting the game
    update(status: 'in_progress', current_turn_server_user: server_users.order(:turn_order).first)
  end


  # For convenience
  def status
    super || 'pending'
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
  def assign_starting_positions(new_user: nil)
    available_cells = grid_cells.where(obstacle: false, owner: nil).to_a
    # Rails.logger.debug "Available cells at start: #{available_cells.map { |c| "(#{c.x}, #{c.y})" }}"

    users_to_assign = new_user ? [new_user] : server_users
    # Rails.logger.debug "Users to assign: #{users_to_assign.map(&:id)}"

    users_to_assign.each do |server_user|
      # Skip users with already assigned positions
      if server_user.current_position_x && server_user.current_position_y
        # Rails.logger.debug "Skipping position assignment for user #{server_user.id} - Already assigned."
        next
      end

      attempts = 0
      assigned = false
      loop do
        starting_cell = available_cells.sample
        # Rails.logger.debug "Trying cell (#{starting_cell.x}, #{starting_cell.y}) for user #{server_user.id}"

        if valid_starting_position?(starting_cell, server_user)
          # Rails.logger.debug "Cell (#{starting_cell.x}, #{starting_cell.y}) is valid for user #{server_user.id}."

          starting_cell.update!(owner: server_user)
          server_user.update!(
            current_position_x: starting_cell.x,
            current_position_y: starting_cell.y
          )

          available_cells.delete(starting_cell)
          # Rails.logger.debug "Assigned cell (#{starting_cell.x}, #{starting_cell.y}) to user #{server_user.id}."
          # Rails.logger.debug "Remaining available cells: #{available_cells.map { |c| "(#{c.x}, #{c.y})" }}"

          assigned = true
          break
        else
          # Rails.logger.debug "Cell (#{starting_cell.x}, #{starting_cell.y}) is not valid for user #{server_user.id}."
        end

        attempts += 1
        raise "Unable to find a valid starting position for #{server_user.user.username}" if attempts > 100
      end

      raise "Position assignment failed for user #{server_user.id}" unless assigned
    end
  end

  def valid_starting_position?(cell, server_user)
    other_server_users = server_users.where.not(id: server_user.id)
                                     .where.not(current_position_x: nil, current_position_y: nil)

    # Allow the position if there are no conflicts with other users
    other_server_users.all? do |other|
      next true if other.current_position_x.nil? || other.current_position_y.nil? # Skip uninitialized users

      distance = [(cell.x - other.current_position_x).abs, (cell.y - other.current_position_y).abs].max
      # Rails.logger.debug "Checking distance: Cell (#{cell.x}, #{cell.y}) to User #{other.id} is #{distance}"

      if distance >= 2 && !cell.obstacle? # Ensure the cell is not occupied by another player or obstacle
        # Rails.logger.debug "Cell (#{cell.x}, #{cell.y}) is valid for User #{server_user.id}."
        true
      else
        # Rails.logger.debug "Cell (#{cell.x}, #{cell.y}) is too close to User #{other.id} or has an obstacle."
        false
      end
    end
  end

end
