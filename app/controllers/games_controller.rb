class GamesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_server
  before_action :set_server_user
  before_action :ensure_game_in_progress
  before_action :ensure_current_player_turn, only: %i[perform_action]
  before_action :set_game, only: [:show, :update_game_area, :update_game_right_panel, :update_game_over, :update_show, :update_game_board, :update_current_turn, :update_inventory, :update_treasures, :update_opponent_details, :update_player_stats,  :update_game_left_panel]
  respond_to :html, :erb, :turbo_stream, :turbostream
  # GET /games/:id
  # app/controllers/games_controller.rb
  # app/controllers/games_controller.rb
  def show
    @server = Server.find(params[:server_id])
    @game = @server.game
    @waiting_for_players = @server.server_users.count < @server.max_players
    Rails.logger.info "waiting_for_players: #{@waiting_for_players}"
    # Rails.logger.info "Loading game data for server #{params[:server_id]}"
    # @server = Server.find(params[:server_id]) # Ensure @server is set
    load_game_data
    # Rails.logger.info "[GamesController#show] Current user token: #{current_user.cable_token}"
    # Rails.logger.info "Game data loaded: server=#{@server.inspect}, game=#{@game.inspect}, server_users=#{@server_users.inspect}, grid_cells=#{@grid_cells.inspect}, server_user=#{@server_user.inspect}, current_turn_user=#{@current_turn_user.inspect}, opponents=#{@opponents.inspect}, waiting_for_players=#{@waiting_for_players.inspect}"
  end
  def perform_action
    @server = Server.find(params[:server_id])
    @game = @server.game
    Rails.logger.info "Performing action: #{params.inspect}"
    Rails.logger.info "Loading game data for server #{params[:server_id]}"
    Rails.logger.info "Action type: #{params[:action_type]}"
    Rails.logger.info "Action direction: #{params[:direction]}"
    Rails.logger.info "@game: #{@game}"
    Rails.logger.info "@server: #{@server}"
    begin
      load_game_data
      success = false

      # ### CHANGED: Ensure action handlers return true on success.
      case params[:action_type]
      when 'move'
        success = handle_move_action(params[:direction])
      when 'occupy'
        success = handle_occupy_action
      when 'capture'
        success = handle_capture_action(params[:direction])
      when 'use_treasure'
        success = handle_use_treasure_action(params[:treasure_id])
      when 'use_item'
        success = handle_use_item_action(params[:item_id])
      when 'purchase_item'
        success = handle_purchase_item_action(params[:item_id])
      else
        handle_error('Invalid action type.')
      end

      # If action wasn't successful, stop here.
      unless success
        # ### CHANGED: Render error turbo_stream if available
        Rails.logger.debug "Action not successful."
        respond_to do |format|
          format.turbo_stream { render partial: "shared/flash", locals: { message: flash[:alert] } }
          format.html { redirect_to server_game_path(@server, @game), alert: flash[:alert] }
        end
        return
      end

      Rails.logger.debug "Action performed successfully"
      Rails.logger.debug "Checking game end conditions"
      check_game_end_conditions
      if @server_user.turn_ap.zero? || @end_turn
        advance_turn
      end
      Rails.logger.debug "Broadcasting game state"
      broadcast_game_state

      respond_to do |format|
        format.html do
          redirect_to server_game_path(@server, @game), notice: 'Action completed successfully.'
        end
        format.json { render json: { message: 'Action completed successfully.' } }
        format.turbo_stream do
          # ### CHANGED: Ensure we render perform_action.turbo_stream.erb fully
          render "perform_action"
        end
      end

    rescue => e
      Rails.logger.error "Error in perform_action: #{e.message}\n#{e.backtrace.join("\n")}"
      flash[:alert] = "An error occurred: #{e.message}"
      respond_to do |format|
        format.html { redirect_to server_game_path(@server, @game), alert: flash[:alert] }
        format.json { render json: { error: e.message }, status: :unprocessable_entity }
        format.turbo_stream { render partial: "shared/flash", locals: { message: flash[:alert] } }
      end
    end
  end


  def update_game_board
    load_game_data
    broadcast_update("game-board", "games/game_board")
  end

  def update_current_turn
    load_game_data
    broadcast_update("current-turn", "games/current_turn")
  end

  def update_inventory
    load_game_data
    broadcast_update("inventory-container", "games/inventory")
  end

  def update_treasures
    load_game_data
    broadcast_update("treasures-container", "games/treasures")
  end

  def update_opponent_details
    load_game_data
    broadcast_update("opponent-details", "games/opponent_details")
  end

  def update_player_stats
    load_game_data
    broadcast_update("player-stats", "games/player_stats")
  end

  def update_game_area
    load_game_data
    broadcast_update("game-show", "games/game_area")
  end

  def update_game_right_panel
    load_game_data
    broadcast_update("game-right-panel", "games/game_right_panel")
  end

  def update_game_over
    load_game_data
    @winner = @game.winner
    broadcast_update("game-over", "games/game_over")
  end
  def update_game_left_panel
    load_game_data
    Rails.logger.info "@server.server_users.count: #{@server.server_users.count}"
    Rails.logger.info "@server.max_players: #{@server.max_players}"

    Rails.logger.info "Rendering update_game_left_panel with waiting_for_players: #{@waiting_for_players.inspect}"

    broadcast_update("game-left-panel", "games/game_left_panel")
  end
  def update_show
    load_game_data
    broadcast_update("game-show", "games/area")
  end

  def ensure_game_in_progress
    load_game_data
    redirect_to servers_path, alert: 'Game is not in progress.' unless @server.status == 'in_progress'
  end

  def ensure_current_player_turn
    load_game_data
    unless @server.current_turn_server_user == @server_user
      flash[:alert] = "It's not your turn."
      redirect_to server_game_path(@server, @game) and return
    end
  end
  private
  def load_game_data
    @grid_cells = @server.grid_cells.includes(:owner, :treasure) || []
    @server_users = @server.server_users.includes(:user)

    @server_user = @server.server_users.find_by(user: current_user)
    @current_turn_user = @server.current_turn_server_user || @server.server_users.order(:turn_order).first
    @opponents = @server.server_users.includes(:user, :treasures) || []
    @waiting_for_players = @server.server_users.count < @server.max_players
    @items = @server_user.game_items
                         .joins(:server_user_items)
                         .where(server_user_items: { used: false })
    @treasures = @server_user&.treasures
    @winner = @game&.winner
  end
  def locals_hash
    {
      server: @server,
      game: @game,
      server_users: @server_users,
      grid_cells: @grid_cells,
      server_user: @server_user,
      current_turn_user: @current_turn_user,
      opponents: @opponents,
      waiting_for_players: @waiting_for_players,
      items:@items,
      treasures: @treasures,
      winner: @winner
    }
  end
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
          return false
        elsif @server.server_users.any? { |su| su.current_position_x == target_x && su.current_position_y == target_y }
          flash[:alert] = 'Cell is occupied by another player.'
          return false
        else
          @server_user.update(current_position_x: target_x, current_position_y: target_y)
          check_for_treasure(target_cell)
          flash[:notice] = 'Moved successfully.'
          return true
        end
      else
        flash[:alert] = 'Invalid move.'
        return false
      end
    else
      flash[:alert] = 'Not enough AP to move.'
      return false
    end
  end



  def handle_occupy_action
    if @server_user == @server.current_turn_server_user && @server_user.spend_turn_ap(1)
      current_cell = @server.grid_cells.find_by(x: @server_user.current_position_x, y: @server_user.current_position_y)
      if current_cell.owner.nil?
        current_cell.update(owner: @server_user)
        flash[:notice] = 'Cell occupied successfully.'
        return true
      else
        flash[:alert] = 'Cell is already occupied.'
        return false
      end
    else
      flash[:alert] = 'Not enough AP to occupy or not your turn.'
      return false
    end
  end


  # New method to handle treasure usage
  # In GamesController
  def handle_use_treasure_action(treasure_id)
    if @server_user == @server.current_turn_user
      treasure = @server_user.treasures.find_by(id: treasure_id)
      if treasure
        apply_treasure_effect(treasure)
        @server_user.treasures.delete(treasure) # Remove after applying effect
        flash[:notice] = "Used treasure: #{treasure.name}"
        return true
      else
        handle_error('Treasure not found.')
        return false
      end
    else
      handle_error("It's not your turn.")
      return false
    end
  end

  def apply_treasure_effect(treasure)
    target_user_id = params[:target_user_id]
    target_server_user = @server.server_users.find_by(user_id: target_user_id)

    # Mirror Shield logic
    if target_server_user&.mirror_shield
      target_server_user.update(mirror_shield: false)
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

    # Apply treasure effects if no mirror reflection or after handling it
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
      apply_treasure_effect(random_treasure)
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
  def handle_capture_action(direction)
    # Adjust costs if needed, or logic. Ensure return true on success.
    if @server_user == @server.current_turn_server_user && @server_user.spend_total_ap(4) && @server_user.spend_turn_ap(1)
      dx, dy = movement_delta(direction)
      target_x = @server_user.current_position_x + dx
      target_y = @server_user.current_position_y + dy

      if valid_position?(target_x, target_y)
        target_cell = @server.grid_cells.find_by(x: target_x, y: target_y)
        if target_cell&.owner && target_cell.owner != @server_user
          if target_cell.fortified? || target_cell.obstacle?
            flash[:alert] = 'Cannot capture a Fortified cell or an Obstacle.'
            return false
          else
            target_cell.update(owner: @server_user)
            flash[:notice] = "Captured opponent's cell."
            return true
          end
        else
          flash[:alert] = 'No opponent cell to capture.'
          return false
        end
      else
        flash[:alert] = 'Invalid capture action.'
        return false
      end
    else
      flash[:alert] = 'Not enough AP to capture or not your turn.'
      return false
    end
  end


  def handle_use_item_action(item_id)
    if @server_user == @server.current_turn_user
      server_user_item = @server_user.server_user_items.find_by(item_id: item_id, used: false)
      if server_user_item
        item = server_user_item.item
        usage_cost = item.usage_ap_cost || 10
        if @server_user.spend_total_ap(usage_cost)
          apply_item_effect(item)
          server_user_item.update!(used: true)
          flash[:notice] = "Used item: #{item.name}"
          return true
        else
          flash[:alert] = 'Not enough AP to use this item.'
          return false
        end
      else
        flash[:alert] = 'Item not found in your game inventory or already used.'
        return false
      end
    else
      flash[:alert] = 'It is not your turn.'
      return false
    end
  end

  def handle_purchase_item_action(item_id)
    item = Item.find_by(id: item_id)
    if item && @server_user.shard_balance >= item.price
      @server_user.adjust_shard_balance(-item.price)
      # Add to user's global inventory (not server_user)
      current_user.inventories.create!(item_id: item.id, quantity: 1)
      flash[:notice] = "Purchased item: #{item.name}"
      return true
    else
      flash[:alert] = 'Unable to purchase item.'
      return false
    end
  end



  def broadcast_game_state
    # Update all relevant parts of the UI
    update_game_board
    update_game_right_panel
    update_game_left_panel
    update_current_turn
    update_opponent_details
    update_player_stats
    update_treasures
    update_inventory
  end

  def render_error_response
    render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash", locals: { message: "Action failed!" })
  end

  def broadcast_update(target, partial)
    load_game_data
    Turbo::StreamsChannel.broadcast_replace_to(
      @server,
      target: target,
      partial: partial,
      locals: locals_hash
    )
  end

  def handle_error(message)
    flash[:alert] = message
    false
  end


  def set_server
    @server = Server.includes(:game).find(params[:server_id])
  end

  def set_server_user
    @server_user = @server.server_users.find_by(user: current_user)
    if @server_user.nil?
      redirect_to servers_path, alert: 'You are not part of this game.'
    end
  end



  def advance_turn
    @server.increment!(:turn_count)
    @server_user.decrement_temporary_effects

    @server.grid_cells.where(owner: current_user).each do |cell|
      if cell.fortified && cell.fortified > 0
        cell.update(fortified: cell.fortified - 1)
      end
    end

    loop do
      next_server_user = find_next_server_user(@server.current_turn_server_user.turn_order)
      if next_server_user.nil?
        @server.update(current_turn_server_user: @server.server_users.order(:turn_order).first)
        return
      end
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
    update_current_turn
    update_game_right_panel
    update_game_board
    update_opponent_details
    update_player_stats
  end

  def find_next_server_user(current_order = @server_user.turn_order)
    next_server_user = @server.server_users.order(:turn_order).where('turn_order > ?', current_order).first
    next_server_user ||= @server.server_users.order(:turn_order).first
  end

  # Action Handlers

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
      treasure = cell.treasure
      # Transfer ownership to the player, but do not apply effect now
      treasure.update!(owner: @server_user, grid_cell: nil)
      cell.update!(treasure: nil)
      # Now the treasure will appear in @server_user.treasures for later use.
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
    return if @server.server_users.count < @server.max_players

    if all_cells_occupied? || single_player_remaining?
      winner = determine_winner
      if winner
        @server.update(status: 'finished')
        @game.update(winner: winner.user.username)
        update_game_over
      else
        flash[:alert] = 'Unable to determine a winner.'
      end
    end
  end

  def all_cells_occupied?
    @server.grid_cells.where(owner_id: nil).count.zero?
  end

  def single_player_remaining?
    @server.server_users.where.not(total_ap: 0).count == 1
  end

  def determine_winner
    sorted_users = @server.server_users.sort_by do |user|
      [-@server.grid_cells.where(owner: user).count, -user.shard_balance]
    end
    winner = sorted_users.first
    if winner
      distribute_bounty(winner)
      flash[:notice] = "#{winner.user.username} wins the game!"
    end
    winner
  end

  def distribute_bounty(winner)
    game_pot = @server.server_users.count * 200
    winner.adjust_shard_balance(game_pot)
    flash[:notice] = "Winner awarded with #{game_pot} Shards!"
  end
  def set_game
    @server = Server.includes(:game).find(params[:server_id]) # Find the server
    @game = @server.game # Access the associated game
    #Rails.logger.info "Finding game with ID: #{params[:id]} for server ID: #{@server.id}"
  end


end
