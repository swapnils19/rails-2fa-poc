# Rails 2FA POC Testing Guide

This Rails application demonstrates Two-Factor Authentication (2FA) using Devise, ROTP, and QR codes.

## Features

- User authentication with Devise
- Two-Factor Authentication with ROTP (Time-based One-Time Passwords)
- QR code generation for easy setup with authenticator apps
- Modern, responsive UI with Tailwind CSS

## Testing the 2FA Functionality

### Prerequisites

1. Install an authenticator app on your phone:
   - Google Authenticator (iOS/Android)
   - Authy (iOS/Android)
   - Microsoft Authenticator (iOS/Android)
   - Any TOTP-compatible app

### Step-by-Step Testing

1. **Start the Rails server** (if not already running):
   ```bash
   rails server -p 3101
   ```

2. **Visit the application**:
   Open your browser and go to `http://localhost:3101`

3. **Create a new account**:
   - Click "Sign up"
   - Enter your email and password
   - Click "Sign up"

4. **Set up 2FA**:
   - After logging in, you'll see the dashboard
   - Click "Setup 2FA" button
   - A QR code will be displayed

5. **Scan the QR code**:
   - Open your authenticator app
   - Scan the QR code with your phone
   - The app will start generating 6-digit codes

6. **Verify 2FA setup**:
   - Enter the current 6-digit code from your authenticator app
   - Click "Verify and Enable 2FA"
   - You should see a success message

7. **Test 2FA login**:
   - Log out of the application
   - Try to log in again with your email and password
   - You'll now need to enter the 2FA code from your authenticator app
   - Enter the current 6-digit code in the "2FA Code" field
   - Click "Sign in"

8. **Disable 2FA** (optional):
   - After logging in with 2FA, you can disable it
   - Click "Disable 2FA" and confirm

## Technical Implementation Details

### Gems Used

- **devise**: Authentication framework
- **rotp**: Ruby OTP library for generating and verifying TOTP codes
- **rqrcode**: QR code generation

### Key Components

1. **User Model** (`app/models/user.rb`):
   - `otp_secret`: Stores the secret key for generating TOTP codes
   - `otp_enabled`: Boolean flag to enable/disable 2FA
   - Methods: `generate_otp_secret`, `otp_qr_code`, `verify_otp`, `enable_otp!`, `disable_otp!`

2. **TwoFactor Controller** (`app/controllers/two_factor_controller.rb`):
   - Handles 2FA setup, verification, and disabling

3. **Custom Sessions Controller** (`app/controllers/users/sessions_controller.rb`):
   - Extends Devise sessions controller to handle 2FA verification during login

4. **Views**:
   - Setup page with QR code display
   - Enhanced login form with 2FA code field
   - Dashboard with 2FA management options

### Security Features

- TOTP codes expire every 30 seconds
- Secret keys are securely generated and stored
- 2FA verification is required for every login when enabled
- QR codes contain all necessary information for authenticator apps

## Troubleshooting

### Common Issues

1. **Invalid 2FA Code**:
   - Ensure your phone's time is synchronized
   - TOTP codes are time-sensitive
   - Try the next code if the current one doesn't work

2. **QR Code Not Scanning**:
   - Ensure good lighting and stable phone position
   - Try zooming in/out on the QR code
   - Some authenticator apps work better than others

3. **Lost Access to Authenticator App**:
   - In a production app, you'd want backup codes
   - For this POC, you can disable 2FA in the Rails console:
     ```ruby
     user = User.find_by(email: 'your@email.com')
     user.disable_otp!
     ```

## Next Steps for Production

- Add backup codes for account recovery
- Implement rate limiting for 2FA attempts
- Add email notifications for 2FA changes
- Consider SMS as backup 2FA method
- Add audit logging for security events
