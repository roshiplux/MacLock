# AppLock for macOS

A native macOS application that allows you to lock specific applications and unlock them using Touch ID or password authentication.

## Features

- 🔒 Lock any macOS application
- 🔓 Unlock using Touch ID or password
- ➕ Add applications to the lock list
- ➖ Remove applications from the lock list
- 🚫 Prevent locked applications from launching
- 💻 Optimized for Mac Silicon (Apple Silicon) laptops
- 📦 Easy installation via DMG file

## System Requirements

- macOS 13.0 or later
- Mac with Touch ID (recommended) or password authentication
- Mac Silicon (Apple Silicon) chip recommended

## Installation

### Option 1: DMG Installer (Coming Soon)
1. Download the latest `AppLock.dmg` from the releases page
2. Open the DMG file
3. Drag AppLock to your Applications folder
4. Launch AppLock from Applications

### Option 2: Build from Source

#### Prerequisites
- Xcode 15.0 or later
- macOS 13.0 or later
- Swift 5.9 or later

#### Build Steps
1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd app-lock-macos
   ```

2. Build the project:
   ```bash
   swift build
   ```

3. Run the application:
   ```bash
   swift run
   ```

#### Building with Xcode
1. Open Terminal and navigate to the project directory
2. Generate Xcode project:
   ```bash
   swift package generate-xcodeproj
   ```
3. Open `AppLock.xcodeproj` in Xcode
4. Build and run the project (⌘+R)

## Usage

1. **First Launch**: Authenticate using Touch ID or your system password
2. **Adding Apps**: Click "Add App" and select applications you want to lock
3. **Locking**: Added apps will be automatically monitored and blocked from launching
4. **Unlocking**: Use "Unlock All Apps" to temporarily disable app blocking
5. **Managing**: Remove apps from the lock list by clicking the trash icon

## Permissions

AppLock requires the following permissions:
- **Touch ID/Face ID**: For biometric authentication
- **System Administration**: To monitor and control application launches
- **Accessibility**: To interact with other applications (if needed)

Grant these permissions when prompted for full functionality.

## How It Works

1. **Authentication**: Uses Local Authentication framework for Touch ID/password
2. **App Monitoring**: Monitors system for application launch events
3. **App Control**: Terminates locked applications when they attempt to launch
4. **Persistence**: Saves your locked app list using UserDefaults

## Building DMG Installer

To create a DMG installer:

1. Build the release version:
   ```bash
   swift build -c release
   ```

2. Create the DMG (script will be provided):
   ```bash
   ./scripts/create-dmg.sh
   ```

## Development

### Project Structure
```
Sources/
├── AppLockApp.swift        # Main app entry point
├── ContentView.swift       # Main UI
├── AddAppView.swift        # Add app interface
└── AppLockManager.swift    # Core logic and app monitoring

Package.swift               # Swift Package Manager configuration
Info.plist                 # App information and permissions
README.md                  # This file
```

### Key Components

- **AppLockManager**: Handles app monitoring, locking/unlocking logic
- **ContentView**: Main user interface with authentication and app management
- **AddAppView**: Interface for selecting applications to lock
- **Touch ID Integration**: Uses LocalAuthentication framework

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly on macOS
5. Submit a pull request

## Security Notes

- App uses system-level monitoring which requires user permission
- Authentication data is handled by macOS LocalAuthentication framework
- No sensitive data is stored by the application
- App list is stored locally using UserDefaults

## Troubleshooting

### Touch ID Not Working
- Ensure your Mac has Touch ID capability
- Check System Preferences > Touch ID & Password
- Restart the application

### Apps Not Being Blocked
- Grant system administration permissions when prompted
- Check System Preferences > Security & Privacy > Privacy > Accessibility
- Restart AppLock after granting permissions

### Performance Issues
- Limit the number of locked applications
- Restart the application if memory usage is high

## License

This project is licensed under the MIT License. See LICENSE file for details.

## Support

For issues and feature requests, please create an issue on the GitHub repository.

---

**Note**: This application is designed for personal use and educational purposes. Use responsibly and in accordance with your organization's security policies.
