class LeaderboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_leaderboard, only: %i[show edit update destroy]

  # GET /leaderboards
  def index
    @leaderboards = Leaderboard.all
  end

  # GET /leaderboards/:id
  def show
    @entries = @leaderboard.leaderboard_entries.order(rank: :asc).includes(:user)
  end

  # GET /leaderboards/new
  def new
    @leaderboard = Leaderboard.new
  end

  # POST /leaderboards
  def create
    @leaderboard = Leaderboard.new(leaderboard_params)
    if @leaderboard.save
      redirect_to @leaderboard, notice: 'Leaderboard was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /leaderboards/:id/edit
  def edit
  end

  # PATCH/PUT /leaderboards/:id
  def update
    if @leaderboard.update(leaderboard_params)
      redirect_to @leaderboard, notice: 'Leaderboard was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /leaderboards/:id
  def destroy
    @leaderboard.destroy
    redirect_to leaderboards_url, notice: 'Leaderboard was successfully destroyed.'
  end

  private

  def set_leaderboard
    @leaderboard = Leaderboard.find(params[:id])
  end

  def leaderboard_params
    params.require(:leaderboard).permit(:name, :scope, :server_id)
  end
end
