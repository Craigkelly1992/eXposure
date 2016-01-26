class PagesController < ApplicationController
  def home
    redirect_to new_agency_session_path unless current_agency
  end
end
