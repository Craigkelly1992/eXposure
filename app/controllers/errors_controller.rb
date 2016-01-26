class ErrorsController < ApplicationController

  def not_found
    respond_to do |format|
      format.html { render :status => 404 }
      format.json { render json: {message: "Page not found"}, status: 404 }
    end
  end

  def unacceptable
    respond_to do |format|
      format.html { render :status => 422 }
      format.json { render json: {message: "Page not found"}, status: :unprocessable_entity }
    end
  end

  def internal_error
    respond_to do |format|
      format.html { render :status => 500 }
      format.json { render json: {message: "Server Error"}, status: 500 }
    end
  end

end
