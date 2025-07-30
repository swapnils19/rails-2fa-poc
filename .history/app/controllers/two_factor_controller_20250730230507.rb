class TwoFactorController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def setup
    if @user.otp_enabled?
      redirect_to root_path, notice: '2FA is already enabled for your account.'
      return
    end

    @user.generate_otp_secret unless @user.otp_secret
    @user.save!
    @qr_code = @user.otp_qr_code
  end

  def verify
    token = params[:token]

    if @user.verify_otp(token)
      @user.enable_otp!
      redirect_to root_path, notice: '2FA has been successfully enabled!'
    else
      redirect_to setup_two_factor_path, alert: 'Invalid token. Please try again.'
    end
  end

  def disable
    if params[:confirm] == 'yes'
      @user.disable_otp!
      redirect_to root_path, notice: '2FA has been disabled.'
    else
      redirect_to root_path, alert: 'Please confirm to disable 2FA.'
    end
  end

  private

  def set_user
    @user = current_user
  end
end
