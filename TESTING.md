# Testing AppLock Touch ID Functionality

## How to Test:

1. **Install AppLock**:
   - Open `AppLock-1.0.0.dmg`
   - Drag `AppLock.app` to Applications folder
   - Launch AppLock from Applications

2. **Test Touch ID Authentication**:
   - When AppLock opens, it should prompt for Touch ID
   - If Touch ID fails, it will ask for your password

3. **Add and Test App Locking**:
   - Click "Add App" in AppLock
   - Select Zoom.app (or any app) from Applications
   - The app will be added to the locked list
   - Status should show "🔒 Active" and "Monitoring: zoom.app"

4. **Test App Blocking**:
   - Close AppLock (but don't quit it completely)
   - Try to open Zoom from Launchpad or Applications
   - Zoom should start then immediately close
   - Touch ID prompt should appear asking to authenticate for Zoom
   - After successful authentication, Zoom should relaunch

## Debug Information:

If you run AppLock from Terminal with `open dist/AppLock.app`, you can see debug output:
- App launch detection
- Authentication attempts
- App blocking/allowing decisions

## Notes:

- AppLock must remain running in background for monitoring to work
- The first launch will request notification permissions
- Touch ID is primary authentication, password is fallback
- You can disable locking temporarily with "Disable Locking" button

## Troubleshooting:

- If Touch ID doesn't appear: Check System Preferences > Touch ID & Password
- If apps don't get blocked: Make sure AppLock is still running
- If authentication fails: Try using password instead of Touch ID
