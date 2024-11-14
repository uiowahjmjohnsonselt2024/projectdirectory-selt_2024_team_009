class ScoresController < ApplicationController
  before_action :authenticate_user!
  before_action :set_score, only: %i[show edit update destroy]

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
end
