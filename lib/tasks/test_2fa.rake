namespace :test do
  desc "Generate current TOTP code for a user (for testing without phone)"
  task :generate_2fa_code, [:email] => :environment do |task, args|
    email = args[:email] || ENV['EMAIL']

    if email.blank?
      puts "Usage: rails test:generate_2fa_code[user@example.com]"
      puts "   or: EMAIL=user@example.com rails test:generate_2fa_code"
      exit 1
    end

    user = User.find_by(email: email)

    if user.nil?
      puts "User with email '#{email}' not found"
      exit 1
    end

    if !user.otp_enabled?
      puts "2FA is not enabled for user '#{email}'"
      puts "Secret: #{user.otp_secret || 'Not set'}"
      exit 1
    end

    current_code = ROTP::TOTP.new(user.otp_secret).now
    next_code = ROTP::TOTP.new(user.otp_secret).at(Time.now + 30)

    puts "=" * 50
    puts "2FA Codes for: #{email}"
    puts "=" * 50
    puts "Current code (valid for ~30 seconds): #{current_code}"
    puts "Next code (valid after current expires): #{next_code}"
    puts "=" * 50
    puts "Time: #{Time.now}"
    puts "Secret: #{user.otp_secret}"
  end

  desc "Setup 2FA for a user via console (for testing)"
  task :setup_2fa, [:email] => :environment do |task, args|
    email = args[:email] || ENV['EMAIL']

    if email.blank?
      puts "Usage: rails test:setup_2fa[user@example.com]"
      exit 1
    end

    user = User.find_by(email: email)

    if user.nil?
      puts "User with email '#{email}' not found"
      exit 1
    end

    user.generate_otp_secret
    user.save!

    puts "=" * 60
    puts "2FA Setup for: #{email}"
    puts "=" * 60
    puts "Secret: #{user.otp_secret}"
    puts "QR Code URL: #{user.otp_qr_code}"
    puts ""
    puts "Manual entry details for authenticator app:"
    puts "Account: #{email}"
    puts "Key: #{user.otp_secret}"
    puts "Type: Time-based"
    puts "=" * 60
  end

  desc "Debug 2FA token validation"
  task :debug_2fa, [:email, :token] => :environment do |task, args|
    email = args[:email] || ENV['EMAIL']
    token = args[:token] || ENV['TOKEN']

    if email.blank? || token.blank?
      puts "Usage: rails test:debug_2fa[user@example.com,123456]"
      puts "   or: EMAIL=user@example.com TOKEN=123456 rails test:debug_2fa"
      exit 1
    end

    user = User.find_by(email: email)

    if user.nil?
      puts "User with email '#{email}' not found"
      exit 1
    end

    puts "=" * 70
    puts "2FA Debug Information for: #{email}"
    puts "=" * 70
    puts "User OTP Secret: #{user.otp_secret}"
    puts "User OTP Enabled: #{user.otp_enabled?}"
    puts "Input Token: #{token}"
    puts "Current Time: #{Time.now}"
    puts "Current Timestamp: #{Time.now.to_i}"
    puts ""

    # Generate current and nearby codes
    totp = ROTP::TOTP.new(user.otp_secret)
    current_time = Time.now

    puts "Generated codes for different time windows:"
    (-2..2).each do |offset|
      time_offset = current_time + (offset * 30)
      code = totp.at(time_offset)
      status = code == token ? " ⭐ MATCH!" : ""
      puts "  #{offset == 0 ? 'CURRENT' : sprintf('%+2d', offset * 30).rjust(7)}s: #{code}#{status} (#{time_offset})"
    end

    puts ""
    puts "Verification results:"
    puts "  Direct verification: #{user.verify_otp(token)}"
    puts "  ROTP verify (no drift): #{totp.verify(token, drift_behind: 0, drift_ahead: 0)}"
    puts "  ROTP verify (30s drift): #{totp.verify(token, drift_behind: 30, drift_ahead: 30)}"
    puts "  ROTP verify (60s drift): #{totp.verify(token, drift_behind: 60, drift_ahead: 60)}"
    puts "=" * 70
  end

  desc "List all users and their 2FA status"
  task :list_users => :environment do
    puts "=" * 60
    puts "All Users and their 2FA Status"
    puts "=" * 60

    User.all.each do |user|
      puts "Email: #{user.email}"
      puts "  2FA Enabled: #{user.otp_enabled?}"
      puts "  OTP Secret: #{user.otp_secret ? 'Set' : 'Not set'}"
      puts "  Created: #{user.created_at}"
      puts ""
    end

    if User.count == 0
      puts "No users found. Create a user first."
    end
    puts "=" * 60
  end
end
