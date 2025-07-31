#!/usr/bin/env ruby
require_relative 'config/environment'

email = 'abcd@123.com'

puts "=" * 70
puts "🔧 FIXING 2FA SYNC FOR: #{email}"
puts "=" * 70

# Find user
user = User.find_by(email: email)

if user.nil?
  puts "❌ User not found. Available users:"
  User.all.each { |u| puts "  - #{u.email}" }
  exit 1
end

# Generate a completely new secret
puts "🔄 Generating new OTP secret..."
user.generate_otp_secret
user.update!(otp_enabled: false)  # Reset to disabled state
user.save!

puts "✅ New OTP secret generated: #{user.otp_secret}"
puts ""

# Generate QR code details
require 'rotp'
totp = ROTP::TOTP.new(user.otp_secret, issuer: "Rails 2FA POC")
provisioning_uri = totp.provisioning_uri(email)

puts "🔗 QR Code Information:"
puts "Provisioning URI: #{provisioning_uri}"
puts ""
puts "📱 Manual entry details for authenticator app:"
puts "  Account: #{email}"
puts "  Key: #{user.otp_secret}"
puts "  Type: Time-based"
puts "  Algorithm: SHA1"
puts "  Digits: 6"
puts "  Period: 30 seconds"
puts ""

# Generate current expected codes
puts "⏰ Current expected codes:"
current_time = Time.now
(-1..1).each do |offset|
  time_offset = current_time + (offset * 30)
  code = totp.at(time_offset)
  status = offset == 0 ? " ⬅️ CURRENT" : ""
  puts "  #{sprintf('%+3d', offset * 30).rjust(4)}s: #{code}#{status}"
end

puts ""
puts "=" * 70
puts "🎯 NEXT STEPS:"
puts "1. DELETE the old entry from your authenticator app"
puts "2. Go to: http://localhost:3101/two_factor/setup"
puts "3. Scan the NEW QR code (or manually enter the key above)"
puts "4. Enter a fresh 6-digit code to verify"
puts "=" * 70
