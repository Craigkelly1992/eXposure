class BrandsController < ApplicationController
  include BrandsHelper
  before_filter :authenticate_admin!, only: [:index]
  before_action :authenticate_agency!, only: [:create, :update, :destroy, :edit, :new, :my]
  before_action :set_brand, only: [:show, :edit, :update, :destroy]
  before_action :correct_agency, only: [:edit, :update, :destroy]
  # GET /brands
  # GET /brands.json
  def index
    @brands = Brand.all
  end

  def my
    #Rails.logger.error(User.find(43).device_token)
    @brands = current_agency.brands.paginate(page: params[:page])
    render 'my_brands'
  end

  # GET /brands/1
  # GET /brands/1.json
  def show
    @contests = @brand.contests.paginate(page: params[:page])
    impressionist(@brand, 'brandview', :unique => [:impressionable_type, :impressionable_id, :session_hash])
  end

  # GET /brands/new
  def new
    @brand = current_agency.brands.build
    2.times {@brand.photos.build}
  end

  # GET /brands/1/edit
  def edit
  end

  # POST /brands
  # POST /brands.json
  def create
    @brand = current_agency.brands.build(brand_params)

    respond_to do |format|
      if @brand.save
        format.html { redirect_to @brand, notice: 'Brand was successfully created.' }
        format.json { render :show, status: :created, location: @brand }
      else
        format.html { render :new }
        format.json { render json: @brand.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /brands/1
  # PATCH/PUT /brands/1.json
  def update
    respond_to do |format|
      if @brand.update(brand_params)
        format.html { redirect_to @brand, notice: 'Brand was successfully updated.' }
        format.json { render :show, status: :ok, location: @brand }
      else
        format.html { render :edit }
        format.json { render json: @brand.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /brands/1
  # DELETE /brands/1.json
  def destroy
    @brand.destroy
    respond_to do |format|
      format.html { redirect_to my_brands_url, notice: 'Brand was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def visit_brand_social
    if params[:target] && ["website", "facebook", "twitter", "instagram"].include?(params[:target])
      @brand = Brand.find(params[:id])
      impressionist(@brand, params[:target])
      redirect_to redirect_types(params[:target],@brand)
    else
      @json = {status: false, message: "Wrong or no target specified"}
      respond_with @json, status: :unprocessable_entity, location: "/"
    end
  end

  private
  def correct_agency
    redirect_to root_path unless @brand.agency == current_agency
  end
  # Use callbacks to share common setup or constraints between actions.
  def set_brand
    @brand = Brand.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def brand_params
    params.require(:brand).permit(:name, :facebook, :twitter, :instagram, :slogan, :website, :description, :picture,
                                  photos_attributes: [:picture, :id])
  end
end
