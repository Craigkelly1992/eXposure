class API::AgenciesController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :authenticate_user_from_token!
end