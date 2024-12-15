class ScoresController < ApplicationController
  before_action :authenticate_user!
  before_action :set_server, only: %i[show edit update destroy start]
  # POST /servers/:id/start
  def start
    if @server.status != 'pending'
      redirect_to @server, alert: 'Game has already started or finished.'
      return
    end

    if @server.server_users.count < 2
      redirect_to @server, alert: 'At least 2 players are required to start the game.'
      return
    end

    # Assign symbols and turn order
    assign_symbols_and_turn_order

    # Assign starting positions
    assign_starting_positions

    # Initialize the grid with treasures and obstacles
    initialize_grid

    # Update server status
    @server.update(status: 'in_progress', current_turn_server_user_id: @server.server_users.order(:turn_order).first.id)

    redirect_to server_game_path(@server, @server.game), notice: 'Game started successfully.'
  end
  # GET /scores
  def index
    @scores = current_user.scores.includes(:server)
  end

  # GET /scores/:id
  def show
  end

  # GET /scores/new
  def new
    @score = current_user.scores.build
  end

  # POST /scores
  def create
    @score = current_user.scores.build(score_params)
    if @score.save
      redirect_to @score, notice: 'Score was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /scores/:id/edit
  def edit
  end

  # PATCH/PUT /scores/:id
  def update
    if @score.update(score_params)
      redirect_to @score, notice: 'Score was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /scores/:id
  def destroy
    @score.destroy
    redirect_to scores_url, notice: 'Score was successfully destroyed.'
  end

  private

  def set_score
    @score = current_user.scores.find(params[:id])
  end

  def score_params
    params.require(:score).permit(:server_id, :points, :level)
  end
  def assign_symbols_and_turn_order
    symbols = ['🟢', '🔴', '🔵', '🟡', '🟣', '🟤'].shuffle
    turn_orders = (1..@server.server_users.count).to_a.shuffle

    @server.server_users.each_with_index do |server_user, index|
      server_user.update(symbol: symbols[index], turn_order: turn_orders[index])
    end
  end

  def assign_starting_positions
    available_cells = @server.grid_cells.to_a
    occupied_positions = []

    @server.server_users.each do |server_user|
      possible_cells = available_cells.select do |cell|
        valid_starting_position?(cell, occupied_positions)
      end

      if possible_cells.empty?
        redirect_to @server, alert: 'Unable to assign starting positions with required distance.'
        return
      end

      starting_cell = possible_cells.sample
      server_user.update(current_position_x: starting_cell.x, current_position_y: starting_cell.y)
      occupied_positions << starting_cell
      available_cells.delete(starting_cell)
    end
  end

  def valid_starting_position?(cell, occupied_positions)
    occupied_positions.all? do |occupied_cell|
      manhattan_distance(cell, occupied_cell) >= 3
    end
  end

  def manhattan_distance(cell1, cell2)
    (cell1.x - cell2.x).abs + (cell1.y - cell2.y).abs
  end

  def initialize_grid
    # Create grid cells for a 6x6 grid
    (0..5).each do |x|
      (0..5).each do |y|
        GridCell.create(server: @server, x: x, y: y)
      end
    end

    # Place treasures and obstacles randomly
    grid_cells = @server.grid_cells.to_a.shuffle
    treasures = Treasure.all.sample(10)

    grid_cells[0...10].each_with_index do |cell, index|
      cell.update(treasure: treasures[index])
    end

    grid_cells[10...20].each do |cell|
      cell.update(obstacle: true)
    end
  end
end
