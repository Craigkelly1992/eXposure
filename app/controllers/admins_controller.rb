class AdminsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_agency, only: [:disable_agency, :enable_agency, :delete_agency]
  before_action :set_user, only: [:disable_user, :enable_user, :delete_user]

  def users
    @users = User.all.paginate(page: params[:page])
  end

  def agencies
    @agencies = Agency.all.paginate(page: params[:page])
  end

  def disable_agency
    @agency.update_attributes(enabled: nil)
    redirect_to admin_agencies_path(page: params[:page])
  end

  def enable_agency
    @agency.update_attributes(enabled: true)
    redirect_to admin_agencies_path(page: params[:page])
  end

  def delete_agency
    @agency.destroy
    redirect_to admin_agencies_path(page: params[:page])
  end

  def disable_user
    @user.update_attributes(enabled: nil)
    redirect_to admin_users_path(page: params[:page])
  end

  def enable_user
    @user.update_attributes(enabled: true)
    redirect_to admin_users_path(page: params[:page])
  end

  def delete_user
    @user.destroy
    redirect_to admin_users_path(page: params[:page])
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_agency
    @agency = Agency.find(params[:agency_id])
  end

end