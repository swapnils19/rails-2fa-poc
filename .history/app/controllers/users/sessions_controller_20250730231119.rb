# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    
    if resource.otp_enabled?
      if params[:user][:otp_code].blank?
        flash[:alert] = "Please enter your 2FA code"
        render :new and return
      end
      
      unless resource.verify_otp(params[:user][:otp_code])
        flash[:alert] = "Invalid 2FA code"
        render :new and return
      end
    end
    
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_code])
  end
end
