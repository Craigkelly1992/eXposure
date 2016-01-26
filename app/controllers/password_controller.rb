class PasswordController < Devise::PasswordsController
  before_action :authenticate_user!
  respond_to :json
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    if successfully_sent?(resource)
      json = {:message => "Please check your email for change the password"}
      respond_with json, location: "/"
    else
      respond_with(resource)
    end
  end

  def edit
    super
  end

  def new
    super
  end
end