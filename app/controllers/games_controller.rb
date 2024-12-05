class GamesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_server
  before_action :set_server_user
  before_action :ensure_game_in_progress
  before_action :ensure_current_player_turn, only: %i[perform_action]
  before_action :ensure_shard_payment, only: [:start_game]

  # POST /games/:id/start_game
  def start_game
    if @server.status != 'pending'
      redirect_to @server, alert: 'Game has already started or finished.'
      return
    end

    unless @server.server_users.all? { |su| su.user.wallet.balance >= 200 }
      redirect_to @server, alert: 'Not all players have 200 shards. Ensure every player has sufficient balance to start the game.'
      return
    end

    # Deduct 200 shards from each player
    @server.server_users.each do |server_user|
      wallet = server_user.user.wallet
      Rails.logger.debug "Before deduction: #{wallet.balance} shards for #{server_user.user.email}"
      wallet.update!(balance: wallet.balance - 200)
      Rails.logger.debug "After deduction: #{wallet.balance} shards for #{server_user.user.email}"

    end

    @server.start_game
    redirect_to game_path(@server), notice: 'Game started successfully.'

  end

  def ensure_shard_payment
    wallet = current_user.wallet

    if wallet.balance < 200
      redirect_to wallets_path, alert: 'Need at least 200 shards to start game'
      return false
    end
    wallet.balance -= 200
    if wallet.save
      flash[:notice] = '200 shards have been deducted to start the game.'
    else
      redirect_to wallets_path, alert: 'Shard deduction failed. Please try again.'
    end
  end

  def distribute_shard_pool_to_winner(winner)

    total_shard_pool = @server.server_users.sum(:shards_paid_to_start)
    winner.adjust_shard_balance(total_shard_pool)

    flash[:notice] = "#{total_shard_pool} Shards have been awarded to the winner!"
  end

  def deduct_shards_for_game_start
    if @server_user.wallet.balance >= 200
      @server_user.wallet.update(balance: @server_user.wallet.balance - 200)
      @server_user.update(shards_paid_to_start: 200)
    else
      redirect_to game_path(@server), alert: 'Not enough shards to start the game.'
    end
  end

  # GET /games/:id
  def show
    @grid_cells = @server.grid_cells.includes(:owner, :treasure)
    @server_users = @server.server_users.includes(:user)
    @server_user ||= @server.server_users.find_by(user: current_user)

    @current_turn_user = @server.current_turn_server_user || @server.server_users.order(:turn_order).first
    # Check if the required number of players has joined
    @waiting_for_players = @server.server_users.count < @server.max_players
    if @waiting_for_players
      ActionCable.server.broadcast(
        "game_#{@server.id}",
        {
          type: "waiting_for_players",
          message: "Waiting for players to join. Current: #{@server.server_users.count}/#{@server.max_players}"
        }
      )
    else
      ActionCable.server.broadcast(
        "game_#{@server.id}",
        { type: "all_players_joined" }
      )
    end
    @opponents = @server.server_users.includes(:user, :treasures)|| []
  end

  # GET /games/:id/play_turn
  # def play_turn
  #   @server_user.reset_turn_ap if @server_user.turn_ap <= 0
  #   @items = current_user.inventories.includes(:item)
  # end

  # POST /games/:id/perform_action
  # POST /games/:id/perform_action
  def perform_action
    if @server.server_users.count < @server.max_players
      return handle_error('Not enough players have joined the game.')
    end
    @server_users = @server.server_users.includes(:user)

    action_type = params[:action_type]
    case action_type
    when 'move'
      unless handle_move_action(params[:direction])
        return handle_error('Invalid move. Please try again.')
      end
    when 'occupy'
      unless handle_occupy_action
        return handle_error('Unable to occupy the cell.')
      end
    when 'capture'
      unless handle_capture_action(params[:direction])
        return handle_error('Capture action failed.')
      end
    when 'use_treasure'
      unless handle_use_treasure_action(params[:treasure_id])
        return handle_error('Treasure usage failed. Ensure you have the treasure.')
      end
    else
      return handle_error('Invalid action type.')
    end
    broadcast_game_updates
    update_player_stats
    update_opponents
    check_game_end_conditions

    if @server_user.turn_ap <= 0
      advance_turn
      message = 'Turn ended due to insufficient action points.'
    elsif @end_turn
      advance_turn
      message = 'Turn ended manually.'
    else
      message = 'Action performed successfully.'
    end

    respond_to do |format|
      format.html { redirect_to game_path(@server), notice: message }
      format.json { render json: { success: true, message: message }, status: :ok }
    end
  end



  private
  def handle_error(message)
    respond_to do |format|
      format.html { redirect_to game_path(@server), alert: message }
      format.json { render json: { success: false, message: message }, status: :unprocessable_entity }
    end
  end
  def update_opponents
    @opponents = @server.server_users.where.not(id: @server_user.id)
    GameChannel.broadcast_to(
      @server,
      type: "opponent_stats_updated",
      html: render_to_string(partial: "games/opponent_details", locals: { opponents: @opponents })
    )
  end

  def update_player_stats
    GameChannel.broadcast_to(
      @server,
      type: "player_stats_updated",
      html: render_to_string(partial: "games/player_stats", locals: { player: @server_user })
    )
  end
  def broadcast_game_updates
    # Render updated partials for opponents and player stats
    opponents_html = render_to_string(partial: "games/opponent_details", locals: { opponents: @opponents })
    player_stats_html = render_to_string(partial: "games/player_stats", locals: { player: @server_user })

    # Broadcast the updates
    ActionCable.server.broadcast(
      "game_#{@server.id}",
      {
        type: "update_stats",
        opponents_html: opponents_html,
        player_stats_html: player_stats_html
      }
    )
  end


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
      respond_to do |format|
        format.html { redirect_to game_path(@server), alert: 'It is not your turn.' }
        format.json { render json: { success: false, message: 'It is not your turn.' }, status: :forbidden }
      end
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

    @server.current_turn_server_user.update(turn_ap: 2)
  end

  def find_next_server_user(current_order = @server_user.turn_order)
    next_server_user = @server.server_users.order(:turn_order).where('turn_order > ?', current_order).first
    next_server_user ||= @server.server_users.order(:turn_order).first
  end

  # Action Handlers
  def handle_move_action(direction)
    if @server_user == @server.current_turn_server_user && @server_user.spend_turn_ap(1)
      dx, dy = movement_delta(direction)
      target_x = @server_user.current_position_x + dx
      target_y = @server_user.current_position_y + dy

      if valid_position?(target_x, target_y)
        is_diagonal = dx.abs == 1 && dy.abs == 1
        if is_diagonal && !@server_user.can_move_diagonally
          flash[:alert] = 'Diagonal movement is not allowed.'
          return false
        end

        target_cell = @server.grid_cells.find_by(x: target_x, y: target_y)
        if target_cell.obstacle?
          flash[:alert] = 'Cannot move to an obstacle.'
        elsif @server.server_users.any? { |su| su.current_position_x == target_x && su.current_position_y == target_y }
          flash[:alert] = 'Cell is occupied by another player.'
        else
          @server_user.update(current_position_x: target_x, current_position_y: target_y)
          check_for_treasure(target_cell)
          flash[:notice] = 'Moved successfully.'
          broadcast_game_updates
          return true
        end
      else
        flash[:alert] = 'Invalid move.'
      end
    else
      flash[:alert] = 'Not enough AP to move.'
    end
    false
  end

  def handle_occupy_action
    if @server_user == @server.current_turn_server_user && @server_user.spend_turn_ap(1)
      current_cell = @server.grid_cells.find_by(x: @server_user.current_position_x, y: @server_user.current_position_y)
      if current_cell.owner.nil?
        current_cell.update(owner: @server_user)
        flash[:notice] = 'Cell occupied successfully.'
        broadcast_game_updates
        return true
      else
        flash[:alert] = 'Cell is already occupied.'
      end
    else
      flash[:alert] = 'Not enough AP to occupy or it is not your turn.'
    end
    false
  end


  # New method to handle treasure usage
  def handle_use_treasure_action(treasure_id)
    # Ensure the current player is taking their turn
    if @server_user == @server.current_turn_server_user
      treasure = @server_user.treasures.find_by(id: treasure_id)

      unless treasure
        flash[:alert] = 'Treasure not found or unavailable.'
        return false
      end

      # Apply the effect of the treasure
      apply_treasure_effect(treasure)
      @server_user.treasures.delete(treasure) # Remove the treasure after usage
      flash[:notice] = "Used treasure: #{treasure.name}"
      true
    else
      flash[:alert] = 'It is not your turn.'
      false
    end
  end

  def handle_capture_action(direction)
    if @server_user == @server.current_turn_server_user && @server_user.spend_turn_ap(3)
      dx, dy = movement_delta(direction)
      target_x = @server_user.current_position_x + dx
      target_y = @server_user.current_position_y + dy

      if valid_position?(target_x, target_y)
        target_cell = @server.grid_cells.find_by(x: target_x, y: target_y)
        if target_cell.owner && target_cell.owner != @server_user
          if target_cell.fortified?
            flash[:alert] = 'Cannot capture a fortified cell.'
          else
            target_cell.update(owner: @server_user)
            flash[:notice] = 'Captured opponent\'s cell.'
            return true
          end
        else
          flash[:alert] = 'No opponent cell to capture.'
        end
      else
        flash[:alert] = 'Invalid capture action.'
      end
    else
      flash[:alert] = 'Not enough AP to capture or it is not your turn.'
    end
    false
  end


  def handle_use_item_action(item_id)
    if @server_user == @server.current_turn_server_user
      inventory = current_user.inventories.find_by(item_id: item_id)
      if inventory
        item = inventory.item
        usage_cost = item.usage_ap_cost || 10
        if @server_user.spend_total_ap(usage_cost)
          apply_item_effect(item)
          inventory.destroy
          flash[:notice] = "Used item: #{item.name}"
          return true
        else
          flash[:alert] = 'Not enough AP to use this item.'
        end
      else
        flash[:alert] = 'Item not found in inventory.'
      end
    else
      flash[:alert] = 'It is not your turn.'
    end
    false
  end


  def handle_purchase_item_action(item_id)
    if @server_user == @server.current_turn_server_user
      item = Item.find(item_id)
      if @server_user.shard_balance >= item.price
        @server_user.adjust_shard_balance(-item.price)
        current_user.inventories.create(item: item)
        flash[:notice] = 'Item purchased successfully.'
        return true
      else
        flash[:alert] = 'Not enough Shards to purchase this item.'
      end
    else
      flash[:alert] = 'It is not your turn.'
    end
    false
  end



  # Helper Methods
  def movement_delta(direction)
    case direction.downcase
    when 'up' then [0, 1] # Increase y for up
    when 'down' then [0, -1] # Decrease y for down
    when 'left' then [-1, 0] # Decrease x for left
    when 'right' then [1, 0] # Increase x for right
    when 'up_left' then [-1, 1] # Diagonal: up and left
    when 'up_right' then [1, 1] # Diagonal: up and right
    when 'down_left' then [-1, -1] # Diagonal: down and left
    when 'down_right' then [1, -1] # Diagonal: down and right
    else [0, 0] # No movement
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
    # Ensure the current player is acting on their turn
    return unless @server_user == @server.current_turn_server_user

    target_user_id = params[:target_user_id]
    target_server_user = @server.server_users.find_by(user_id: target_user_id)

    # Handle Mirror Shield logic
    if target_server_user&.mirror_shield
      target_server_user.mirror_shield = false
      target_server_user.save
      flash[:notice] = 'Your action was reflected back by Mirror Shield!'

      case treasure.name
      when 'Energy Siphon'
        amount_to_steal = 5
        if @server_user.total_ap >= amount_to_steal
          @server_user.update(total_ap: @server_user.total_ap - amount_to_steal)
          target_server_user.update(total_ap: target_server_user.total_ap + amount_to_steal)
          flash[:notice] = 'Your AP was stolen due to Mirror Shield.'
        else
          flash[:alert] = 'You do not have enough AP to be stolen.'
        end
      else
        flash[:alert] = 'Treasure effect reflected, but no logic implemented for this treasure.'
      end
      return
    end

    # Process specific treasure effects
    case treasure.name
    when 'Winged Amulet'
      @server_user.update(can_move_diagonally: true, diagonal_moves_left: 1)
      flash[:notice] = 'You can make one diagonal move without AP cost.'

    when 'Golden Key'
      target_x = params[:target_x].to_i
      target_y = params[:target_y].to_i
      handle_occupy_cell(target_x, target_y)

    when 'Shard Cache'
      @server_user.adjust_shard_balance(30)
      flash[:notice] = 'Gained 30 Shards.'

    when 'Mirror Shield'
      @server_user.update(mirror_shield: true)
      flash[:notice] = 'Mirror Shield activated. The next action against you will be reflected.'

    when 'Time Crystal'
      @server_user.update(turn_ap: @server_user.turn_ap + 2)
      flash[:notice] = 'Gained 2 extra AP for this turn.'

    when 'Energy Siphon'
      siphon_ap_from_opponent(target_user_id, 5)

    when 'Mystery Box'
      random_treasure = Treasure.where.not(id: treasure.id).sample
      process_treasure(random_treasure)
      flash[:notice] = "Mystery Box activated: #{random_treasure.name}"

    when 'Barrier Stone'
      target_x = params[:target_x].to_i
      target_y = params[:target_y].to_i
      handle_place_obstacle(target_x, target_y)

    when 'Teleport Crystal'
      target_x = params[:target_x].to_i
      target_y = params[:target_y].to_i
      handle_teleport_to_cell(target_x, target_y)

    when 'Capture Charm'
      direction = params[:direction]
      dx, dy = movement_delta(direction)
      handle_capture_cell(dx, dy)

    else
      flash[:alert] = 'Treasure effect not implemented.'
    end
  end



  def apply_item_effect(item)
    return unless @server_user == @server.current_turn_server_user

    target_user_id = params[:target_user_id]
    target_server_user = @server.server_users.find_by(user_id: target_user_id)

    # Handle Mirror Shield logic
    if target_server_user&.mirror_shield
      target_server_user.update(mirror_shield: false)
      flash[:notice] = 'Your action was reflected back by Mirror Shield!'

      case item.name
      when 'AP Stealer'
        amount_to_steal = 10
        if @server_user.total_ap >= amount_to_steal
          @server_user.update(total_ap: @server_user.total_ap - amount_to_steal)
          target_server_user.update(total_ap: target_server_user.total_ap + amount_to_steal)
          flash[:notice] = 'Your AP was stolen due to Mirror Shield.'
        else
          flash[:alert] = 'You do not have enough AP to be stolen.'
        end
      else
        flash[:alert] = 'Action reflected, but no logic implemented for this item.'
      end
      return
    end

    # Process specific item effects
    case item.name
    when 'Teleportation Scroll'
      target_x = params[:target_x].to_i
      target_y = params[:target_y].to_i
      handle_teleport_to_cell(target_x, target_y)

    when 'Time Skip Device'
      skip_next_player_turn

    when 'AP Booster'
      @server_user.update(total_ap: @server_user.total_ap + 20)
      flash[:notice] = 'Gained 20 AP to your total AP pool.'

    when 'Energy Drink'
      @server_user.update(turn_ap: @server_user.turn_ap + 2)
      flash[:notice] = 'Gained 2 extra AP for this turn.'

    when 'AP Stealer'
      siphon_ap_from_opponent(target_user_id, 10)

    when 'Treasure Detector'
      current_cell = @server.grid_cells.find_by(x: @server_user.current_position_x, y: @server_user.current_position_y)
      if current_cell.treasure
        flash[:notice] = 'A treasure is already present here.'
      else
        random_treasure = Treasure.all.sample
        current_cell.update(treasure: random_treasure)
        flash[:notice] = "Activated a treasure: #{random_treasure.name}"
      end

    when 'Diagonal Boots'
      @server_user.update(can_move_diagonally: true, diagonal_moves_left: 3)
      flash[:notice] = 'You can now move diagonally for the next 3 turns.'

    when 'Fortification Kit'
      target_x = params[:target_x].to_i
      target_y = params[:target_y].to_i
      handle_fortify_cell(target_x, target_y)

    when 'Obstacle Remover'
      direction = params[:direction]
      dx, dy = movement_delta(direction)
      handle_remove_obstacle(dx, dy)

    when 'Swap Positions'
      handle_swap_positions(target_user_id)

    else
      flash[:alert] = 'Item effect not implemented.'
    end
  end
  def siphon_ap_from_opponent(target_user_id, amount)
    target_server_user = @server.server_users.find_by(user_id: target_user_id)
    if target_server_user && target_server_user != @server_user
      if target_server_user.total_ap >= amount
        target_server_user.update(total_ap: target_server_user.total_ap - amount)
        @server_user.update(total_ap: @server_user.total_ap + amount)
        flash[:notice] = "Stole #{amount} AP from an opponent."
      else
        flash[:alert] = 'Opponent does not have enough AP.'
      end
    else
      flash[:alert] = 'Invalid opponent selected.'
    end
  end
  def handle_teleport_to_cell(x, y)
    if valid_position?(x, y)
      target_cell = @server.grid_cells.find_by(x: x, y: y)
      if target_cell && !target_cell.occupied? && !target_cell.obstacle?
        @server_user.update(current_position_x: x, current_position_y: y)
        flash[:notice] = 'Teleported successfully.'
      else
        flash[:alert] = 'Target cell is occupied or has an obstacle.'
      end
    else
      flash[:alert] = 'Invalid target position.'
    end
  end
  def handle_place_obstacle(x, y)
    if valid_position?(x, y)
      cell = @server.grid_cells.find_by(x: x, y: y)
      if cell && !cell.obstacle? && !cell.occupied?
        cell.update(obstacle: true)
        flash[:notice] = 'Placed an obstacle on the selected cell.'
      else
        flash[:alert] = 'Cannot place obstacle on the selected cell.'
      end
    else
      flash[:alert] = 'Invalid position.'
    end
  end



  def item_usage_ap_cost(item)
    # Return usage cost based on item
    item.name == 'Diagonal Boots' ? 10 : 10
  end

  def check_game_end_conditions
    return if @server.server_users.count < @server.max_players # Ensure all players have joined

    if all_cells_occupied? || single_player_remaining?
      winner = determine_winner
      if winner
        @server.update(status: 'finished')

        # Broadcast game over and winner information
        ActionCable.server.broadcast(
          "game_#{@server.id}",
          {
            type: "game_over",
            message: "Game Over! The winner is #{winner.user.username} with #{winner.total_ap} AP and #{winner.shard_balance} Shards!",
            winner: winner.user.username,
            stats: {
              cells_owned: @server.grid_cells.where(owner_id: winner.user_id).count,
              shards: winner.shard_balance
            }
          }
        )
      else
        flash[:alert] = 'Unable to determine a winner due to invalid game state.'
      end
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
    # Check if only one player remains in the game
    @server.server_users.where.not(total_ap: 0).count == 1
  end


  def determine_winner
    # Determines the winner based on cells owned and shard balance
    winner = @server.server_users.max_by do |server_user|
      owned_cells_count = @server.grid_cells.where(owner: server_user).count
      [owned_cells_count, server_user.shard_balance]
    end

    if winner
      distribute_bounty(winner)
      flash[:notice] = "#{winner.user.username} wins the game!"
    else
      flash[:alert] = 'Could not determine a winner due to an invalid state.'
    end

    winner
  end


  def distribute_bounty(winner)
    # Distributes a game-ending bounty to the winner
    game_pot = @server.server_users.count * 200
    winner.adjust_shard_balance(game_pot)
    flash[:notice] = "Winner awarded with #{game_pot} Shards!"
  end

end
