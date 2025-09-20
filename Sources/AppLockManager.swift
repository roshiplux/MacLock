import Foundation
import AppKit
import ServiceManagement
import UserNotifications
import LocalAuthentication

class AppLockManager: ObservableObject {
    @Published var lockedApps: [String] = []
    @Published var isLockingEnabled = true
    @Published var autoStartEnabled = true
    private let userDefaults = UserDefaults.standard
    private let lockedAppsKey = "LockedApps"
    private let autoStartKey = "AutoStartEnabled"
    private var pendingApps: [NSRunningApplication] = []
    
    init() {
        loadLockedApps()
        loadAutoStartSetting()
        // Delay notification permission request to avoid crash in command line
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.requestNotificationPermission()
        }
        setupAppMonitoring()
        // Setup auto-start if enabled
        if autoStartEnabled {
            setupAutoStart()
        }
    }
    
    func addApp(_ appName: String) {
        if !lockedApps.contains(appName) {
            lockedApps.append(appName)
            saveLockedApps()
        }
    }
    
    func removeApp(_ appName: String) {
        lockedApps.removeAll { $0 == appName }
        saveLockedApps()
    }
    
    func lockAllApps() {
        isLockingEnabled = true
        for appName in lockedApps {
            lockApp(appName)
        }
    }
    
    func unlockAllApps() {
        isLockingEnabled = false
        for appName in lockedApps {
            unlockApp(appName)
        }
    }
    
    private func lockApp(_ appName: String) {
        // Terminate the application if it's running
        let runningApps = NSWorkspace.shared.runningApplications
        for app in runningApps {
            if let bundleURL = app.bundleURL,
               bundleURL.lastPathComponent == appName {
                app.terminate()
                break
            }
        }
        
        // Set up monitoring to prevent the app from launching
        enableAppBlocking(for: appName)
    }
    
    private func unlockApp(_ appName: String) {
        disableAppBlocking(for: appName)
    }
    
    private func enableAppBlocking(for appName: String) {
        // This would require system-level permissions and possibly a helper tool
        // For now, we'll implement a basic version that monitors and terminates
        print("Blocking enabled for: \(appName)")
    }
    
    private func disableAppBlocking(for appName: String) {
        print("Blocking disabled for: \(appName)")
    }
    
    private func setupAppMonitoring() {
        // Monitor for app launches
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didLaunchApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
               let bundleURL = app.bundleURL {
                let appName = bundleURL.lastPathComponent
                
                print("🔍 App launched: \(appName)")
                print("🔍 Locked apps: \(self?.lockedApps ?? [])")
                print("🔍 Locking enabled: \(self?.isLockingEnabled ?? false)")
                
                if self?.lockedApps.contains(appName) == true && self?.isLockingEnabled == true {
                    print("🚫 Blocking \(appName) - authentication required")
                    // Show authentication dialog before allowing the app to run
                    self?.handleLockedAppLaunch(app: app, appName: appName)
                } else {
                    print("✅ Allowing \(appName) to run")
                }
            }
        }
        
        print("📡 App monitoring setup complete")
    }
    
    private func handleLockedAppLaunch(app: NSRunningApplication, appName: String) {
        // Don't block if locking is disabled
        guard isLockingEnabled else { return }
        
        // Store the app reference for potential restoration
        pendingApps.append(app)
        
        // Terminate the app first
        app.terminate()
        
        // Show authentication dialog immediately on main thread
        DispatchQueue.main.async {
            self.authenticateForApp(appName: appName, originalApp: app)
        }
    }
    
    private func authenticateForApp(appName: String, originalApp: NSRunningApplication) {
        // Bring AppLock to front for authentication
        NSApp.activate(ignoringOtherApps: true)
        
        let context = LAContext()
        var error: NSError?
        
        // First check what authentication methods are available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "🔒 Mac Lock by PluxCore\n\n\(appName) is protected. Use Touch ID to continue."
            
            // Set app display name for authentication dialog
            context.localizedFallbackTitle = "Use Password"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        print("✅ Touch ID authentication successful for \(appName)")
                        // Authentication successful - relaunch the app
                        self.launchApp(appName: appName)
                    } else {
                        print("❌ Touch ID failed for \(appName), trying password...")
                        // Try password authentication as fallback
                        self.authenticateWithPasswordForApp(appName: appName)
                    }
                    
                    // Remove from pending apps
                    self.pendingApps.removeAll { $0 == originalApp }
                }
            }
        } else {
            print("Touch ID not available, using password authentication")
            // Fallback to password authentication
            authenticateWithPasswordForApp(appName: appName)
        }
    }
    
    private func authenticateWithPasswordForApp(appName: String) {
        let context = LAContext()
        let reason = "🔒 Mac Lock by PluxCore\n\n\(appName) is protected. Enter your password to continue."
        
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
            DispatchQueue.main.async {
                if success {
                    print("✅ Password authentication successful for \(appName)")
                    // Authentication successful - relaunch the app
                    self.launchApp(appName: appName)
                } else {
                    print("❌ Password authentication failed for \(appName)")
                    // Show notification that access was denied
                    self.showAccessDeniedNotification(for: appName)
                }
            }
        }
    }
    
    private func launchApp(appName: String) {
        // Find the app path and launch it
        let applicationsURL = URL(fileURLWithPath: "/Applications")
        let appURL = applicationsURL.appendingPathComponent(appName)
        
        print("🚀 Attempting to launch \(appName) at \(appURL.path)")
        
        if FileManager.default.fileExists(atPath: appURL.path) {
            // Temporarily disable monitoring to prevent re-blocking
            let wasEnabled = isLockingEnabled
            isLockingEnabled = false
            
            NSWorkspace.shared.openApplication(at: appURL, configuration: NSWorkspace.OpenConfiguration()) { app, error in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    // Re-enable monitoring after app has launched
                    self.isLockingEnabled = wasEnabled
                }
                
                if let error = error {
                    print("❌ Failed to launch \(appName): \(error)")
                } else {
                    print("✅ Successfully launched \(appName)")
                }
            }
        } else {
            print("❌ App not found at \(appURL.path)")
            // Try to find the app in other common locations
            findAndLaunchApp(appName: appName)
        }
    }
    
    private func findAndLaunchApp(appName: String) {
        // Enhanced search paths including more common locations
        let searchPaths = [
            "/Applications",
            "/System/Applications",
            "/Applications/Utilities",
            "/System/Library/PreferencePanes",
            "/Library/PreferencePanes",
            "~/Applications",
            "/opt/homebrew/Applications",
            "/usr/local/Applications"
        ].map { path in
            if path.hasPrefix("~") {
                return NSString(string: path).expandingTildeInPath
            }
            return path
        }
        
        // First try exact match
        for searchPath in searchPaths {
            let appURL = URL(fileURLWithPath: searchPath).appendingPathComponent(appName)
            if FileManager.default.fileExists(atPath: appURL.path) {
                print("🔍 Found \(appName) at \(appURL.path)")
                launchAppAtURL(appURL, appName: appName)
                return
            }
        }
        
        // If exact match fails, try fuzzy matching (case insensitive, partial match)
        print("🔍 Trying fuzzy search for \(appName)...")
        for searchPath in searchPaths {
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: searchPath)
                for item in contents {
                    if item.lowercased().contains(appName.lowercased().replacingOccurrences(of: ".app", with: "")) ||
                       appName.lowercased().contains(item.lowercased().replacingOccurrences(of: ".app", with: "")) {
                        let appURL = URL(fileURLWithPath: searchPath).appendingPathComponent(item)
                        var isDirectory: ObjCBool = false
                        if FileManager.default.fileExists(atPath: appURL.path, isDirectory: &isDirectory) && 
                           (isDirectory.boolValue || item.hasSuffix(".app")) {
                            print("🔍 Fuzzy match found: \(item) at \(appURL.path)")
                            launchAppAtURL(appURL, appName: appName)
                            return
                        }
                    }
                }
            } catch {
                // Silently continue if we can't read directory
                continue
            }
        }
        
        // Try using Spotlight to find the app
        print("🔍 Trying Spotlight search for \(appName)...")
        findAppUsingSpotlight(appName: appName)
    }
    
    private func launchAppAtURL(_ appURL: URL, appName: String) {
        // Temporarily disable monitoring
        let wasEnabled = isLockingEnabled
        isLockingEnabled = false
        
        NSWorkspace.shared.openApplication(at: appURL, configuration: NSWorkspace.OpenConfiguration()) { app, error in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                // Re-enable monitoring after app has launched
                self.isLockingEnabled = wasEnabled
            }
            
            if let error = error {
                print("❌ Failed to launch \(appName): \(error)")
                self.showAppLaunchFailedNotification(for: appName, error: error.localizedDescription)
            } else {
                print("✅ Successfully launched \(appName)")
            }
        }
    }
    
    private func findAppUsingSpotlight(appName: String) {
        let query = "kMDItemContentType == 'com.apple.application-bundle' && kMDItemFSName == '*\(appName.replacingOccurrences(of: ".app", with: ""))*'"
        let spotlightQuery = NSMetadataQuery()
        spotlightQuery.searchScopes = [NSMetadataQueryLocalComputerScope]
        spotlightQuery.predicate = NSPredicate(fromMetadataQueryString: query)
        
        spotlightQuery.start()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            spotlightQuery.stop()
            
            if spotlightQuery.resultCount > 0,
               let firstResult = spotlightQuery.result(at: 0) as? NSMetadataItem,
               let path = firstResult.value(forAttribute: NSMetadataItemPathKey) as? String {
                let appURL = URL(fileURLWithPath: path)
                print("🔍 Spotlight found \(appName) at \(path)")
                self.launchAppAtURL(appURL, appName: appName)
            } else {
                print("❌ Could not find \(appName) using any method")
                self.showAppNotFoundNotification(for: appName)
            }
        }
    }
    
    private func showAppNotFoundNotification(for appName: String) {
        // Only show notifications if we're in a proper app context
        guard Bundle.main.bundleIdentifier != nil,
              let _ = NSClassFromString("UNUserNotificationCenter") else {
            print("📢 AppLock: Could not find \(appName) to relaunch. Please check if the app is installed.")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "AppLock"
        content.body = "Could not find \(appName) to relaunch. Please check if the app is installed."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "app-not-found-\(appName)-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to show notification: \(error)")
            }
        }
    }
    
    private func showAccessDeniedNotification(for appName: String) {
        // Only show notifications if we're in a proper app context
        guard Bundle.main.bundleIdentifier != nil,
              let _ = NSClassFromString("UNUserNotificationCenter") else {
            print("📢 AppLock: Access denied for \(appName). Authentication failed.")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "AppLock"
        content.body = "Access denied for \(appName). Authentication failed."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "access-denied-\(appName)-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to show notification: \(error)")
            }
        }
    }
    
    private func showAppLaunchFailedNotification(for appName: String, error: String) {
        // Only show notifications if we're in a proper app context
        guard Bundle.main.bundleIdentifier != nil,
              let _ = NSClassFromString("UNUserNotificationCenter") else {
            print("📢 MacLock: Failed to launch \(appName). Error: \(error)")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Mac Lock"
        content.body = "Failed to launch \(appName). \(error)"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "app-launch-failed-\(appName)-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to show notification: \(error)")
            }
        }
    }
    
    private func requestNotificationPermission() {
        // Only request notifications if we're running in a proper app context
        guard Bundle.main.bundleIdentifier != nil,
              NSApp.applicationIconImage != nil else {
            print("⚠️ Skipping notification permission request - not in proper app context")
            return
        }
        
        // Additional safety check for UserNotifications availability
        guard let _ = NSClassFromString("UNUserNotificationCenter") else {
            print("⚠️ UserNotifications framework not available")
            return
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Notification permission error: \(error)")
                } else if granted {
                    print("✅ Notification permission granted")
                } else {
                    print("⚠️ Notification permission denied")
                }
            }
        }
    }
    
    private func saveLockedApps() {
        userDefaults.set(lockedApps, forKey: lockedAppsKey)
    }
    
    private func loadLockedApps() {
        if let apps = userDefaults.array(forKey: lockedAppsKey) as? [String] {
            lockedApps = apps
        }
    }
    
    private func loadAutoStartSetting() {
        // Default to true for first launch
        if userDefaults.object(forKey: autoStartKey) == nil {
            autoStartEnabled = true
            userDefaults.set(true, forKey: autoStartKey)
        } else {
            autoStartEnabled = userDefaults.bool(forKey: autoStartKey)
        }
    }
    
    func setAutoStart(_ enabled: Bool) {
        autoStartEnabled = enabled
        userDefaults.set(enabled, forKey: autoStartKey)
        
        if enabled {
            setupAutoStart()
        } else {
            removeAutoStart()
        }
    }
    
    private func setupAutoStart() {
        // Create launch agent plist for auto-start
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.pluxcore.maclock"
        let executablePath = Bundle.main.executablePath ?? "/usr/local/bin/maclock"
        
        // Create LaunchAgents directory if it doesn't exist
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let launchAgentsDirectory = homeDirectory.appendingPathComponent("Library/LaunchAgents")
        
        do {
            try FileManager.default.createDirectory(at: launchAgentsDirectory, withIntermediateDirectories: true)
            
            let plistURL = launchAgentsDirectory.appendingPathComponent("\(bundleIdentifier).plist")
            
            let plistContent = """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
                <key>Label</key>
                <string>\(bundleIdentifier)</string>
                <key>ProgramArguments</key>
                <array>
                    <string>\(executablePath)</string>
                </array>
                <key>RunAtLoad</key>
                <true/>
                <key>KeepAlive</key>
                <false/>
                <key>StandardOutPath</key>
                <string>/tmp/applock.out</string>
                <key>StandardErrorPath</key>
                <string>/tmp/applock.err</string>
            </dict>
            </plist>
            """
            
            try plistContent.write(to: plistURL, atomically: true, encoding: .utf8)
            
            // Load the launch agent
            let process = Process()
            process.launchPath = "/bin/launchctl"
            process.arguments = ["load", plistURL.path]
            process.launch()
            process.waitUntilExit()
            
            print("✅ Auto-start enabled for MacLock")
            
        } catch {
            print("❌ Failed to setup auto-start: \(error)")
        }
    }
    
    private func removeAutoStart() {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.pluxcore.maclock"
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let launchAgentsDirectory = homeDirectory.appendingPathComponent("Library/LaunchAgents")
        let plistURL = launchAgentsDirectory.appendingPathComponent("\(bundleIdentifier).plist")
        
        // Unload the launch agent
        let process = Process()
        process.launchPath = "/bin/launchctl"
        process.arguments = ["unload", plistURL.path]
        process.launch()
        process.waitUntilExit()
        
        // Remove the plist file
        do {
            try FileManager.default.removeItem(at: plistURL)
            print("✅ Auto-start disabled for MacLock")
        } catch {
            print("❌ Failed to remove auto-start: \(error)")
        }
    }
}
