#!/usr/bin/env ruby
require_relative 'config/environment'

email = 'abcd@123.com'
token = '552849'

puts "=" * 70
puts "2FA Debug Information for: #{email}"
puts "=" * 70

# Find user
user = User.find_by(email: email)

if user.nil?
  puts "❌ User with email '#{email}' not found"
  puts "Available users:"
  User.all.each { |u| puts "  - #{u.email}" }
  exit 1
end

puts "✅ User found: #{user.email}"
puts "User OTP Secret: #{user.otp_secret}"
puts "User OTP Enabled: #{user.otp_enabled?}"
puts "Input Token: #{token}"
puts "Current Time: #{Time.now}"
puts "Current Timestamp: #{Time.now.to_i}"
puts ""

if user.otp_secret.nil?
  puts "❌ No OTP secret set for this user"
  puts "Setting up OTP secret..."
  user.generate_otp_secret
  user.save!
  puts "✅ OTP secret generated: #{user.otp_secret}"
end

# Generate current and nearby codes
require 'rotp'
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
