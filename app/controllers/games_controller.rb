class GamesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_server
  before_action :set_server_user
  before_action :ensure_game_in_progress
  before_action :ensure_current_player_turn, only: %i[play_turn perform_action]

  # GET /games/:id
  def show
    @grid_cells = @server.grid_cells.includes(:owner, :treasure)
    @server_users = @server.server_users.includes(:user)
    @server_user ||= @server.server_users.find_by(user: current_user)
  end

  # GET /games/:id/play_turn
  def play_turn
    @server_user.reset_turn_ap if @server_user.turn_ap <= 0
    @items = current_user.inventories.includes(:item)
  end

  # POST /games/:id/perform_action
  def perform_action
    @server_users = @server.server_users.includes(:user)
    action_type = params[:action_type]

    case action_type
    when 'move'
      handle_move_action
    when 'occupy'
      handle_occupy_action
    when 'capture'
      handle_capture_action
    when 'use_item'
      handle_use_item_action
    when 'purchase_item'
      handle_purchase_item_action
    else
      flash[:alert] = 'Invalid action.'
    end

    check_game_end_conditions

    if @server_user.turn_ap <= 0
      advance_turn
      redirect_to game_path(@server), notice: 'Turn ended.'
    else
      redirect_to play_turn_game_path(@server)
    end
  end

  private

  def set_server
    @server = Server.find(params[:id])
  end

  def set_server_user
    @server_user = @server.server_users.find_by(user: current_user)
  end

  def ensure_game_in_progress
    redirect_to servers_path, alert: 'Game is not in progress.' unless @server.status == 'in_progress'
  end

  def ensure_current_player_turn
    unless @server.current_turn_server_user == @server_user
      redirect_to game_path(@server), alert: 'It is not your turn.'
    end
  end

  def advance_turn
    # Decrement temporary effects for current player
    @server_user.decrement_temporary_effects

    # Decrement fortification counters
    @server.grid_cells.where(owner: current_user).each do |cell|
      if cell.fortified && cell.fortified > 0
        cell.fortified -= 1
        cell.save
      end
    end

    # Skip turns if necessary
    loop do
      next_server_user = find_next_server_user(@server.current_turn_server_user.turn_order)
      if next_server_user.turns_skipped && next_server_user.turns_skipped > 0
        next_server_user.decrement_temporary_effects
        flash[:notice] = "#{next_server_user.user.username}'s turn is skipped."
        @server.update(current_turn_server_user: next_server_user)
      else
        @server.update(current_turn_server_user: next_server_user)
        break
      end
    end

    @server_user.update(turn_ap: 2)
  end

  def find_next_server_user(current_order = @server_user.turn_order)
    next_server_user = @server.server_users.order(:turn_order).where('turn_order > ?', current_order).first
    next_server_user ||= @server.server_users.order(:turn_order).first
  end

  # Action Handlers
  def handle_move_action
    @server_users = @server.server_users.includes(:user)
    if @server_user.spend_turn_ap(1)
      direction = params[:direction]
      dx, dy = movement_delta(direction)
      target_x = @server_user.current_position_x + dx
      target_y = @server_user.current_position_y + dy

      if valid_position?(target_x, target_y)
        is_diagonal = dx.abs == 1 && dy.abs == 1
        if is_diagonal && !@server_user.can_move_diagonally
          flash[:alert] = 'Diagonal movement is not allowed.'
          return
        end

        target_cell = @server.grid_cells.find_by(x: target_x, y: target_y)
        if target_cell.obstacle?
          flash[:alert] = 'Cannot move to an obstacle.'
        elsif @server_users.any? { |su| su.current_position_x == target_x && su.current_position_y == target_y }
          flash[:alert] = 'Cell is occupied by another player.'
        else
          @server_user.update(current_position_x: target_x, current_position_y: target_y)
          check_for_treasure(target_cell)
          flash[:notice] = 'Moved successfully.'
        end
      else
        flash[:alert] = 'Invalid move.'
      end
    else
      flash[:alert] = 'Not enough AP to move.'
    end
  end

  def handle_occupy_action
    if @server_user.spend_turn_ap(1)
      current_cell = @server.grid_cells.find_by(x: @server_user.current_position_x, y: @server_user.current_position_y)
      if current_cell.owner.nil?
        current_cell.update(owner: current_user)
        flash[:notice] = 'Cell occupied.'
      else
        flash[:alert] = 'Cell is already occupied.'
      end
    else
      flash[:alert] = 'Not enough AP to occupy.'
    end
  end

  def handle_capture_action
    if @server_user.spend_turn_ap(3)
      direction = params[:direction]
      dx, dy = movement_delta(direction)
      target_x = @server_user.current_position_x + dx
      target_y = @server_user.current_position_y + dy

      if valid_position?(target_x, target_y)
        target_cell = @server.grid_cells.find_by(x: target_x, y: target_y)
        if target_cell.owner && target_cell.owner != current_user
          if target_cell.fortified?
            flash[:alert] = 'Cannot capture a fortified cell.'
          else
            target_cell.update(owner: current_user)
            flash[:notice] = 'Captured opponent\'s cell.'
          end
        else
          flash[:alert] = 'No opponent cell to capture.'
        end
      else
        flash[:alert] = 'Invalid capture action.'
      end
    else
      flash[:alert] = 'Not enough AP to capture.'
    end
  end

  def handle_use_item_action
    item_id = params[:item_id]
    inventory = current_user.inventories.find_by(item_id: item_id)
    if inventory
      item = inventory.item
      usage_cost = item.usage_ap_cost || 10
      if @server_user.spend_total_ap(usage_cost)
        apply_item_effect(item)
        inventory.destroy
        flash[:notice] = "Used item: #{item.name}"
      else
        flash[:alert] = 'Not enough AP to use this item.'
      end
    else
      flash[:alert] = 'Item not found in inventory.'
    end
  end

  def handle_purchase_item_action
    item = Item.find(params[:item_id])
    if @server_user.shard_balance >= item.price
      @server_user.adjust_shard_balance(-item.price)
      current_user.inventories.create(item: item)
      flash[:notice] = 'Item purchased successfully.'
    else
      flash[:alert] = 'Not enough Shards to purchase this item.'
    end
  end

  # Helper Methods
  def movement_delta(direction)
    case direction
    when 'up' then [0, -1]
    when 'down' then [0, 1]
    when 'left' then [-1, 0]
    when 'right' then [1, 0]
    when 'up_left' then [-1, -1]
    when 'up_right' then [1, -1]
    when 'down_left' then [-1, 1]
    when 'down_right' then [1, 1]
    else [0, 0]
    end
  end

  def valid_position?(x, y)
    x.between?(0, 5) && y.between?(0, 5)
  end

  def check_for_treasure(cell)
    if cell.treasure
      flash[:notice] = "You found a treasure: #{cell.treasure.name}!"
      process_treasure(cell.treasure)
      cell.update(treasure: nil)
    end
  end

  def process_treasure(treasure)
    target_user_id = params[:target_user_id]
    target_server_user = @server.server_users.find_by(user_id: target_user_id)
    if target_server_user&.mirror_shield
      target_server_user.mirror_shield = false
      target_server_user.save
      flash[:notice] = 'Your action was reflected back by Mirror Shield!'
      case treasure.name
      when 'Energy Siphon'
        amount_to_steal = 5
        if @server_user.total_ap >= amount_to_steal
          @server_user.total_ap -= amount_to_steal
          @server_user.save
          target_server_user.total_ap += amount_to_steal
          target_server_user.save
          flash[:notice] = 'Your AP was stolen due to Mirror Shield.'
        else
          flash[:alert] = 'You do not have enough AP to be stolen.'
        end
      else
        flash[:alert] = 'Treasure effect reflected, but no logic implemented for this treasure.'
      end
      return
    end
    case treasure.name
    when 'Winged Amulet'
      # Allows one diagonal move without AP cost
      @server_user.can_move_diagonally = true
      @server_user.diagonal_moves_left = 1
      @server_user.save
      flash[:notice] = 'You can make one diagonal move without AP cost.'

    when 'Golden Key'
      # Occupy any unoccupied cell without moving
      target_x = params[:target_x].to_i
      target_y = params[:target_y].to_i
      if valid_position?(target_x, target_y)
        cell = @server.grid_cells.find_by(x: target_x, y: target_y)
        if cell && !cell.occupied? && !cell.obstacle?
          cell.update(owner: current_user)
          flash[:notice] = 'You have occupied a cell without moving.'
        else
          flash[:alert] = 'Cannot occupy the selected cell.'
        end
      else
        flash[:alert] = 'Invalid position.'
      end

    when 'Shard Cache'
      # Gain 30 Shards immediately
      @server_user.adjust_shard_balance(30)
      flash[:notice] = 'Gained 30 Shards.'

    when 'Mirror Shield'
      # Reflect next item or action used against you back to the user
      @server_user.mirror_shield = true
      @server_user.save
      flash[:notice] = 'Mirror Shield activated. The next action against you will be reflected.'

    when 'Time Crystal'
      # Gain 2 extra AP on current turn
      @server_user.turn_ap += 2
      @server_user.save
      flash[:notice] = 'Gained 2 extra AP for this turn.'

    when 'Energy Siphon'
      # Steal 5 AP from an opponent
      target_user_id = params[:target_user_id]
      target_server_user = @server.server_users.find_by(user_id: target_user_id)
      if target_server_user && target_server_user != @server_user
        if target_server_user.total_ap >= 5
          target_server_user.total_ap -= 5
          target_server_user.save
          @server_user.total_ap += 5
          @server_user.save
          flash[:notice] = 'Stole 5 AP from an opponent.'
        else
          flash[:alert] = 'Opponent does not have enough AP.'
        end
      else
        flash[:alert] = 'Invalid opponent selected.'
      end

    when 'Mystery Box'
      # Activate a random treasure effect
      random_treasure = Treasure.where.not(id: treasure.id).sample
      process_treasure(random_treasure)
      flash[:notice] = "Mystery Box activated: #{random_treasure.name}"

    when 'Barrier Stone'
      # Place an obstacle on any unoccupied cell
      target_x = params[:target_x].to_i
      target_y = params[:target_y].to_i
      if valid_position?(target_x, target_y)
        cell = @server.grid_cells.find_by(x: target_x, y: target_y)
        if cell && !cell.obstacle? && !cell.occupied?
          cell.update(obstacle: true)
          flash[:notice] = 'Placed an obstacle on the selected cell.'
        else
          flash[:alert] = 'Cannot place obstacle on the selected cell.'
        end
      else
        flash[:alert] = 'Invalid position.'
      end

    when 'Teleport Crystal'
      # Teleport to any unoccupied cell
      target_x = params[:target_x].to_i
      target_y = params[:target_y].to_i
      if valid_position?(target_x, target_y)
        target_cell = @server.grid_cells.find_by(x: target_x, y: target_y)
        if !target_cell.obstacle? && !target_cell.occupied?
          @server_user.update(current_position_x: target_x, current_position_y: target_y)
          flash[:notice] = 'Teleported successfully.'
        else
          flash[:alert] = 'Target cell is occupied or has an obstacle.'
        end
      else
        flash[:alert] = 'Invalid target position.'
      end

    when 'Capture Charm'
      # Capture an adjacent opponent's cell without AP cost
      direction = params[:direction]
      dx, dy = movement_delta(direction)
      target_x = @server_user.current_position_x + dx
      target_y = @server_user.current_position_y + dy

      if valid_position?(target_x, target_y)
        target_cell = @server.grid_cells.find_by(x: target_x, y: target_y)
        if target_cell.owner && target_cell.owner != current_user
          target_cell.update(owner: current_user)
          flash[:notice] = 'Captured opponent\'s cell without AP cost.'
        else
          flash[:alert] = 'No opponent cell to capture.'
        end
      else
        flash[:alert] = 'Invalid capture action.'
      end

    else
      flash[:alert] = 'Treasure effect not implemented.'
    end
  end


  def apply_item_effect(item)
    target_user_id = params[:target_user_id]
    target_server_user = @server.server_users.find_by(user_id: target_user_id)
    if target_server_user&.mirror_shield
      target_server_user.mirror_shield = false
      target_server_user.save
      flash[:notice] = 'Your action was reflected back by Mirror Shield!'
      case item.name
      when 'AP Stealer'
        amount_to_steal = 10
        if @server_user.total_ap >= amount_to_steal
          @server_user.total_ap -= amount_to_steal
          @server_user.save
          target_server_user.total_ap += amount_to_steal
          target_server_user.save
          flash[:notice] = 'Your AP was stolen due to Mirror Shield.'
        else
          flash[:alert] = 'You do not have enough AP to be stolen.'
        end
      else
        flash[:alert] = 'Action reflected, but no logic implemented for this item.'
      end
      return
    end
    case item.name
    when 'Teleportation Scroll'
      # Move to any unoccupied cell
      target_x = params[:target_x].to_i
      target_y = params[:target_y].to_i

      if valid_position?(target_x, target_y)
        target_cell = @server.grid_cells.find_by(x: target_x, y: target_y)
        if !target_cell.obstacle? && !target_cell.occupied?
          @server_user.update(current_position_x: target_x, current_position_y: target_y)
          check_for_treasure(target_cell)
          flash[:notice] = 'Teleported successfully.'
        else
          flash[:alert] = 'Target cell is occupied or has an obstacle.'
        end
      else
        flash[:alert] = 'Invalid target position.'
      end

    when 'Time Skip Device'
      # Skip the next player's turn
      next_player = find_next_server_user
      if next_player
        next_player.turns_skipped = 1
        next_player.save
        flash[:notice] = "Next player's turn will be skipped."
      else
        flash[:alert] = 'No next player to skip.'
      end

    when 'AP Booster'
      # Gain 20 AP added to total AP pool
      @server_user.total_ap += 20
      @server_user.save
      flash[:notice] = 'Gained 20 AP to your total AP pool.'

    when 'Energy Drink'
      # Get 2 extra AP for current turn
      @server_user.turn_ap += 2
      @server_user.save
      flash[:notice] = 'Gained 2 extra AP for this turn.'

    when 'AP Stealer'
      # Steal 10 AP from any opponent
      target_user_id = params[:target_user_id]
      target_server_user = @server.server_users.find_by(user_id: target_user_id)
      if target_server_user && target_server_user != @server_user
        if target_server_user.total_ap >= 10
          target_server_user.total_ap -= 10
          target_server_user.save
          @server_user.total_ap += 10
          @server_user.save
          flash[:notice] = 'Stole 10 AP from an opponent.'
        else
          flash[:alert] = 'Opponent does not have enough AP.'
        end
      else
        flash[:alert] = 'Invalid opponent selected.'
      end

    when 'Treasure Detector'
      # Activate a random treasure in current block
      current_cell = @server.grid_cells.find_by(x: @server_user.current_position_x, y: @server_user.current_position_y)
      if current_cell.treasure
        flash[:notice] = 'A treasure is already present here.'
      else
        random_treasure = Treasure.all.sample
        current_cell.update(treasure: random_treasure)
        flash[:notice] = "Activated a treasure: #{random_treasure.name}"
      end

    when 'Diagonal Boots'
      # Allows diagonal movement for next 3 turns
      @server_user.can_move_diagonally = true
      @server_user.diagonal_moves_left = 3
      @server_user.save
      flash[:notice] = 'You can now move diagonally for the next 3 turns.'

    when 'Fortification Kit'
      # Fortify an occupied cell for 2 turns
      target_x = params[:target_x].to_i
      target_y = params[:target_y].to_i
      cell = @server.grid_cells.find_by(x: target_x, y: target_y)
      if cell && cell.owner == current_user
        cell.update(fortified: 2)  # Number of turns fortified
        flash[:notice] = 'Cell fortified for 2 turns.'
      else
        flash[:alert] = 'You can only fortify your own occupied cells.'
      end

    when 'Obstacle Remover'
      # Remove an obstacle from adjacent cell
      direction = params[:direction]
      dx, dy = movement_delta(direction)
      target_x = @server_user.current_position_x + dx
      target_y = @server_user.current_position_y + dy

      if valid_position?(target_x, target_y)
        target_cell = @server.grid_cells.find_by(x: target_x, y: target_y)
        if target_cell.obstacle?
          target_cell.update(obstacle: false)
          flash[:notice] = 'Obstacle removed.'
        else
          flash[:alert] = 'No obstacle in that direction.'
        end
      else
        flash[:alert] = 'Invalid position.'
      end

    when 'Swap Positions'
      # Swap positions with any other player
      target_user_id = params[:target_user_id]
      target_server_user = @server.server_users.find_by(user_id: target_user_id)
      if target_server_user && target_server_user != @server_user
        # Swap positions
        temp_x = @server_user.current_position_x
        temp_y = @server_user.current_position_y

        @server_user.update(
          current_position_x: target_server_user.current_position_x,
          current_position_y: target_server_user.current_position_y
        )

        target_server_user.update(
          current_position_x: temp_x,
          current_position_y: temp_y
        )

        flash[:notice] = 'Positions swapped successfully.'
      else
        flash[:alert] = 'Invalid player selected for swapping.'
      end

    else
      flash[:alert] = 'Item effect not implemented.'
    end
  end


  def item_usage_ap_cost(item)
    # Return usage cost based on item
    item.name == 'Diagonal Boots' ? 10 : 10
  end

  def check_game_end_conditions
    if all_cells_occupied? || max_turns_reached? || single_player_remaining?
      determine_winner
      @server.update(status: 'finished')
    end
  end

  def all_cells_occupied?
    @server.grid_cells.where(owner_id: nil).count.zero?
  end

  def max_turns_reached?
    # Implement logic if tracking turn counts
    false
  end

  def single_player_remaining?
    # Implement logic if players can be eliminated
    false
  end

  def determine_winner
    winner = @server.server_users.max_by do |su|
      owned_cells = @server.grid_cells.where(owner_id: su.user_id).count
      [owned_cells, su.shard_balance]
    end
    distribute_bounty(winner)
    flash[:notice] = "#{winner.user.username} wins the game!"
  end

  def distribute_bounty(winner)
    game_pot = @server.server_users.count * 200
    winner.adjust_shard_balance(game_pot)
  end
end
