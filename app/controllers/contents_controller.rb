class ContentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_content, only: %i[show edit update destroy]

  # GET /contents
  def index
    @contents = Content.all
  end

  # GET /contents/:id
  def show
  end

  # GET /contents/new
  def new
    @content = Content.new
  end

  # POST /contents
  def create
    @content = Content.new(content_params)
    # this relies on magic to handle invalid params.
    # therefore, sad path is to not be tested.

    if @content.save
      redirect_to @content, notice: 'Content was successfully created.'
    else
      # :nocov:
      render :new, status: :unprocessable_entity
      # :nocov:
    end
  end

  # GET /contents/:id/edit
  def edit
  end

  # PATCH/PUT /contents/:id
  def update
    # this relies on magic to handle invalid params.
    # therefore, sad path is to not be tested.
    if @content.update(content_params)
      redirect_to @content, notice: 'Content was successfully updated.'
    else
      # :nocov:
      render :edit, status: :unprocessable_entity
      # :nocov:
    end
  end

  # DELETE /contents/:id
  def destroy
    @content.destroy
    redirect_to contents_url, notice: 'Content was successfully destroyed.'
  end

  private

  def set_content
    @content = Content.find(params[:id])
  end

  def content_params
    params.require(:content).permit(:story_text, :image_url)
  end
end
