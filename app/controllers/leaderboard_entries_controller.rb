class LeaderboardEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_leaderboard_entry, only: %i[show edit update destroy]

  # GET /leaderboard_entries
  def index
    @leaderboard_entries = current_user.leaderboard_entries.includes(:leaderboard)
  end

  # GET /leaderboard_entries/:id
  def show
  end

  # GET /leaderboard_entries/new
  def new
    @leaderboard_entry = current_user.leaderboard_entries.build
  end

  # POST /leaderboard_entries
  def create
    @leaderboard_entry = current_user.leaderboard_entries.build(leaderboard_entry_params)
    if @leaderboard_entry.save
      redirect_to @leaderboard_entry, notice: 'Leaderboard entry was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /leaderboard_entries/:id/edit
  def edit
  end

  # PATCH/PUT /leaderboard_entries/:id
  def update
    if @leaderboard_entry.update(leaderboard_entry_params)
      redirect_to @leaderboard_entry, notice: 'Leaderboard entry was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /leaderboard_entries/:id
  def destroy
    @leaderboard_entry.destroy
    redirect_to leaderboard_entries_url, notice: 'Leaderboard entry was successfully destroyed.'
  end

  private

  def set_leaderboard_entry
    @leaderboard_entry = current_user.leaderboard_entries.find(params[:id])
  end

  def leaderboard_entry_params
    params.require(:leaderboard_entry).permit(:leaderboard_id, :points, :rank)
  end
end
