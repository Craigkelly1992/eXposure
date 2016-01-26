class NotificationsController < ApplicationController
  before_action :authenticate_agency!
  before_action :set_notification, only: [:show, :edit, :update, :destroy]

  # GET /notifications
  # GET /notifications.json
  def index
    @notifications = Notification.all.paginate(page: params[:page])
  end

  # GET /notifications/1
  # GET /notifications/1.json
  def show
  end

  # GET /notifications/new
  def new
    @notification = Notification.new
  end

  # GET /notifications/1/edit
  def edit
  end

  # POST /notifications
  # POST /notifications.json
  def create
    @notification = Notification.new(notification_params)

    if @notification.type == "winner"
      @notification.sender_id = current_agency.id
      @notification.sender_type = "agency"
      @post = @notification.post
      
      @post.selected
      @contest = @post.contest
      @brand = @post.contest.brand
      @notification.sender_picture = @brand.picture_url_thumb
      @notification.sender_name = @brand.name
      @notification.contest_id = @post.contest.id
    else ["like", "comment", "follow"].include? @notification.type
      @notification.sender_type = "user"
    end

    respond_to do |format|
      if @notification.save
        Winner.create(user_id: @notification.receiver_id, contest_id: @contest.id)
        format.html { redirect_to @contest, notice: 'Notification was successfully created.' }
        format.js
      else
        #format.html { render :new }
        format.js
      end
    end
  end

  # PATCH/PUT /notifications/1
  # PATCH/PUT /notifications/1.json
  def update
    respond_to do |format|
      if @notification.update(notification_params)
        format.html { redirect_to @notification, notice: 'Notification was successfully updated.' }
        format.json { render :show, status: :ok, location: @notification }
      else
        format.html { render :edit }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notifications/1
  # DELETE /notifications/1.json
  def destroy
    @notification.destroy
    respond_to do |format|
      format.html { redirect_to notifications_url, notice: 'Notification was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_notification
    @notification = Notification.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def notification_params
    params.require(:notification).permit(:post_id, :receiver_id, :text, :image, :type)
  end
end
