class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Virtual attribute for 2FA code input
  attr_accessor :otp_code

  # 2FA methods
  def generate_otp_secret
    self.otp_secret = ROTP::Base32.random_base32
  end

  def otp_qr_code
    return nil unless otp_secret

    totp = ROTP::TOTP.new(otp_secret, issuer: "Rails 2FA POC")
    qr_code = RQRCode::QRCode.new(totp.provisioning_uri(email))
    qr_code.as_svg(module_size: 4)
  end

  def verify_otp(token)
    return false unless otp_secret

    totp = ROTP::TOTP.new(otp_secret)
    totp.verify(token, drift_ahead: 30, drift_behind: 30)
  end

  def enable_otp!
    generate_otp_secret unless otp_secret
    update!(otp_enabled: true)
  end

  def disable_otp!
    update!(otp_enabled: false, otp_secret: nil)
  end
end
