import SwiftUI
import LocalAuthentication

struct MenuBarView: View {
    @EnvironmentObject var appManager: AppLockManager
    @State private var showingMainWindow = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with company branding
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "lock.shield.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Mac Lock")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 4) {
                            Button(action: {
                                if let url = URL(string: "https://pluxcore.io") {
                                    NSWorkspace.shared.open(url)
                                }
                            }) {
                                Text("PluxCore Solutions")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .underline()
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Text("•")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("@roshiplux")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                
                // Status indicator
                HStack {
                    Circle()
                        .fill(appManager.isLockingEnabled ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    
                    Text(appManager.isLockingEnabled ? "Active" : "Disabled")
                        .font(.caption)
                        .foregroundColor(appManager.isLockingEnabled ? .green : .red)
                    
                    Spacer()
                    
                    Text("\(appManager.lockedApps.count) apps locked")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
            }
            .padding(.bottom, 8)
            .background(Color(.controlBackgroundColor))
            
            Divider()
            
            // Quick actions
            VStack(spacing: 4) {
                MenuButton("Open Settings", icon: "gear") {
                    openMainWindow()
                }
                
                MenuButton("Open Mac Lock", icon: "app.dashed") {
                    openMainWindow()
                }
                
                if appManager.isLockingEnabled {
                    MenuButton("Disable Protection", icon: "lock.open") {
                        appManager.unlockAllApps()
                    }
                } else {
                    MenuButton("Enable Protection", icon: "lock") {
                        appManager.lockAllApps()
                    }
                }
                
                if !appManager.lockedApps.isEmpty {
                    MenuButton("View Locked Apps", icon: "list.bullet") {
                        openMainWindow()
                    }
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                // Auto-start toggle
                HStack {
                    Image(systemName: "power")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .frame(width: 16)
                    
                    Text("Auto-start on Login")
                        .font(.caption)
                    
                    Spacer()
                    
                    Toggle("", isOn: .init(
                        get: { appManager.autoStartEnabled },
                        set: { appManager.setAutoStart($0) }
                    ))
                    .toggleStyle(SwitchToggleStyle())
                    .scaleEffect(0.8)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                
                Divider()
                    .padding(.vertical, 4)
                
                MenuButton("About Mac Lock", icon: "info.circle") {
                    showAbout()
                }
                
                MenuButton("Quit Mac Lock", icon: "power") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .frame(width: 280)
    }
    
    private func openMainWindow() {
        // Close any existing menu bar popover
        NSApp.setActivationPolicy(.regular)
        
        // First, try to find existing MacLock window and reuse it
        let existingWindow = NSApplication.shared.windows.first { window in
            return window.title.contains("Mac Lock") && 
                   window.contentViewController is NSHostingController<ContentView>
        }
        
        if let window = existingWindow {
            // Reuse existing window - just bring it to front and resize properly
            window.setFrame(NSRect(x: 100, y: 100, width: 600, height: 700), display: true)
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        // Check for any hosting view containing ContentView in other windows
        for window in NSApplication.shared.windows {
            if window.contentViewController is NSHostingController<ContentView> {
                window.setFrame(NSRect(x: 100, y: 100, width: 600, height: 700), display: true)
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
                return
            }
        }
        
        // Only create new window if absolutely necessary
        DispatchQueue.main.async {
            
            let contentView = ContentView().environmentObject(appManager)
            let hostingController = NSHostingController(rootView: contentView)
            let window = NSWindow(
                contentRect: NSRect(x: 100, y: 100, width: 600, height: 700),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            
            window.title = "Mac Lock - PluxCore Solutions"
            window.contentViewController = hostingController
            window.center()
            
            // Set proper app icon for the window
            if let appIcon = NSApp.applicationIconImage {
                window.standardWindowButton(.documentIconButton)?.image = appIcon
            }
            
            // Configure window for proper memory management
            window.isReleasedWhenClosed = true
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "Mac Lock by PluxCore"
        alert.informativeText = """
        Version 1.0.0
        
        🏢 Company: PluxCore Solutions
        👨‍💻 Developer: Roshiplux (@roshiplux)
        💬 Discord: 1301049420401475595
        🌐 GitHub: github.com/roshiplux
        
        A professional application security solution for macOS Silicon laptops.
        Protect your applications with Touch ID authentication and password fallback.
        
        Features:
        • Touch ID Authentication
        • Application Monitoring & Blocking
        • Auto-start on Login
        • Menu Bar Operation
        • Professional Security Interface
        
        © 2025 PluxCore Solutions. All rights reserved.
        Built with ❤️ by Roshiplux
        """
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Visit GitHub")
        alert.alertStyle = .informational
        
        let response = alert.runModal()
        if response == .alertSecondButtonReturn {
            if let url = URL(string: "https://github.com/roshiplux") {
                NSWorkspace.shared.open(url)
            }
        }
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    init(_ title: String, icon: String, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
                    .frame(width: 20, alignment: .leading)
                
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { isHovered in
            if isHovered {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}
