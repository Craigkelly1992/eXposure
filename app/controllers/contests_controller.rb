class ContestsController < ApplicationController
  before_action :authenticate_admin!,only: [:index]
  before_action :set_contest, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_agency!, only: [:create, :update, :destroy, :edit, :new, :my, :set_winner]
  before_action :correct_agency, only: [:edit, :update, :destroy]
  impressionist :actions=>[:show, :index], :unique => [:impressionable_type, :impressionable_id, :session_hash]

  # GET /contests
  # GET /contests.json
  def index
    @contests = Contest.all.paginate(page: params[:page]).order(start_date: :desc)
  end

  def my
    @contests = current_agency.contests.paginate(page: params[:page]).order(start_date: :desc)
    render 'my_contests'
  end

  # GET /contests/1
  # GET /contests/1.json
  def show
    @posts = @contest.submissions(:all).paginate(page: params[:page])
  end

  # GET /contests/new
  def new
    @contest = current_agency.contests.build
  end

  # GET /contests/1/edit/my_brands
  def edit
  end

  def winner_window
    @contest = current_agency.contests.find(params[:id])
    @post = Post.find(params[:post_id])
    @winner = @post.user
    @notification = @winner.notifications.build
    respond_to do |format|
      format.js
    end
  end

  # POST /contests
  # POST /contests.json
  def create
    @contest = current_agency.contests.build(contest_params)
    respond_to do |format|
      if @contest.save
        
        FinishContestWorker.perform_at(@contest.end_date, @contest.id) if @contest.voting?
        
        format.html { redirect_to @contest, notice: 'Contest was successfully created.' }
        format.json { render :show, status: :created, location: @contest }
      else
        format.html { render :new }
        format.json { render json: @contest.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contests/1
  # PATCH/PUT /contests/1.json
  def update
    respond_to do |format|
      if @contest.update(contest_params)
        FinishContestWorker.perform_at(@contest.end_date, @contest.id)
        format.html { redirect_to @contest, notice: 'Contest was successfully updated.' }
        format.json { render :show, status: :ok, location: @contest }
      else
        format.html { render :edit }
        format.json { render json: @contest.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contests/1
  # DELETE /contests/1.json
  def destroy
    @contest.destroy
    respond_to do |format|
      format.html { redirect_to my_contests_url, notice: 'Contest was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def correct_agency
    redirect_to root_path unless @contest.brand.agency == current_agency
  end
  # Use callbacks to share common setup or constraints between actions.
  def set_contest
    @contest = Contest.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def contest_params
    params.require(:contest).permit(:brand_id, :title, :description, :rules, :prizes, :voting, :start_date, :end_date, :location, :picture)
  end
end
