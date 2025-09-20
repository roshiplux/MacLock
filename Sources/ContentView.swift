import SwiftUI
import LocalAuthentication

struct ContentView: View {
    @EnvironmentObject var appManager: AppLockManager
    @State private var isAuthenticated = false
    @State private var showingAddApp = false
    @State private var authError: String?
    @State private var isCheckingAuth = false
    
    var body: some View {
        ZStack {
            // Dark mode background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color(red: 0.1, green: 0.1, blue: 0.15)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                if !isAuthenticated {
                    authenticationView
                } else {
                    mainContentView
                }
            }
            .padding(24)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if !isAuthenticated && !isCheckingAuth {
                authenticate()
            }
        }
        .sheet(isPresented: $showingAddApp) {
            AddAppView()
                .environmentObject(appManager)
                .preferredColorScheme(.dark)
        }
    }
    
    private var authenticationView: some View {
        VStack(spacing: 32) {
            // Modern dark header
            VStack(spacing: 16) {
                // App icon and title
                HStack(spacing: 16) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Mac Lock")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Professional Application Security")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                }
                
                // Company branding with your details
                VStack(spacing: 8) {
                    Button(action: {
                        if let url = URL(string: "https://pluxcore.io") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        Text("by PluxCore Solutions")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.cyan)
                            .underline()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onHover { hovering in
                        NSCursor.pointingHand.set()
                    }
                    
                    Text("Developed by Roshiplux")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "person.circle")
                                .foregroundColor(.cyan)
                            Text("@roshiplux")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "message.circle")
                                .foregroundColor(.purple)
                            Text("Discord: 1301049420401475595")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "globe")
                                .foregroundColor(.blue)
                            Button(action: {
                                if let url = URL(string: "https://pluxcore.io") {
                                    NSWorkspace.shared.open(url)
                                }
                            }) {
                                Text("pluxcore.io")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .underline()
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .padding(.top, 20)
            
            // Dark mode authentication card
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Image(systemName: "touchid")
                        .font(.system(size: 48))
                        .foregroundColor(.cyan)
                    
                    Text("Secure Authentication Required")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Authenticate using Touch ID or your system password to access Mac Lock")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
                
                Button(action: authenticate) {
                    HStack(spacing: 12) {
                        Image(systemName: "touchid")
                            .font(.title2)
                        Text("Authenticate")
                            .font(.headline)
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: .cyan.opacity(0.5), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isCheckingAuth)
                
                if let error = authError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.top, 8)
                }
                
                if isCheckingAuth {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.cyan)
                        Text("Authenticating...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(24)
            .background(Color(red: 0.15, green: 0.15, blue: 0.2))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: 16, x: 0, y: 8)
        }
    }
    
    private var mainContentView: some View {
        VStack(spacing: 24) {
            // Dark mode header with company branding
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Mac Lock")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 8) {
                            Button(action: {
                                if let url = URL(string: "https://pluxcore.io") {
                                    NSWorkspace.shared.open(url)
                                }
                            }) {
                                Text("PluxCore Solutions")
                                    .font(.subheadline)
                                    .foregroundColor(.cyan)
                                    .underline()
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Text("•")
                                .foregroundColor(.gray)
                            
                            Text("by @roshiplux")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    // Status badge
                    HStack(spacing: 6) {
                        Circle()
                            .fill(appManager.isLockingEnabled ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        
                        Text(appManager.isLockingEnabled ? "Active" : "Disabled")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(appManager.isLockingEnabled ? .green : .red)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.2, green: 0.2, blue: 0.25))
                    .cornerRadius(12)
                }
            }
            
            // App list section with improved display
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Protected Applications")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(appManager.lockedApps.count) apps")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if appManager.lockedApps.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "plus.circle.dashed")
                                    .font(.system(size: 48))
                                    .foregroundColor(.gray.opacity(0.6))
                                
                                Text("No applications protected yet")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                Text("Click 'Add Application' to start protecting your apps")
                                    .font(.subheadline)
                                    .foregroundColor(.gray.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(32)
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0.15, green: 0.15, blue: 0.2))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        } else {
                            ForEach(appManager.lockedApps, id: \.self) { app in
                                DarkAppRowView(app: app) {
                                    appManager.removeApp(app)
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: 280)
                .background(Color(red: 0.12, green: 0.12, blue: 0.17))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                )
            }
            
            // Dark mode action buttons
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    Button("Add Application") {
                        showingAddApp = true
                    }
                    .buttonStyle(DarkPrimaryButtonStyle())
                    
                    Button(appManager.isLockingEnabled ? "Disable Protection" : "Enable Protection") {
                        if appManager.isLockingEnabled {
                            appManager.unlockAllApps()
                        } else {
                            appManager.lockAllApps()
                        }
                    }
                    .buttonStyle(DarkSecondaryButtonStyle(isDestructive: appManager.isLockingEnabled))
                }
                
                // Auto-start toggle with dark styling
                HStack(spacing: 12) {
                    Image(systemName: "power")
                        .foregroundColor(.cyan)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Auto-Start on Login")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Text("Launch Mac Lock automatically when you log in")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: .init(
                        get: { appManager.autoStartEnabled },
                        set: { appManager.setAutoStart($0) }
                    ))
                    .toggleStyle(SwitchToggleStyle())
                    .tint(.cyan)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(red: 0.15, green: 0.15, blue: 0.2))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                )
            }
            
            // Footer with monitoring info and contact details
            if !appManager.lockedApps.isEmpty {
                VStack(spacing: 8) {
                    Text("Currently monitoring: \(appManager.lockedApps.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "shield.checkered")
                            .font(.caption2)
                        Text("Protected by PluxCore Solutions")
                            .font(.caption2)
                    }
                    .foregroundColor(.gray.opacity(0.7))
                    
                    HStack(spacing: 12) {
                        Text("Contact: @roshiplux")
                            .font(.caption2)
                            .foregroundColor(.cyan.opacity(0.8))
                        
                        Text("Discord: 1301049420401475595")
                            .font(.caption2)
                            .foregroundColor(.purple.opacity(0.8))
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(20)
        .background(Color(red: 0.15, green: 0.15, blue: 0.2))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
    }
    
    private func authenticate() {
        isCheckingAuth = true
        let context = LAContext()
        var error: NSError?
        
        // Check if Touch ID is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access AppLock Pro"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    self.isCheckingAuth = false
                    if success {
                        self.isAuthenticated = true
                        self.authError = nil
                    } else {
                        self.authError = "Touch ID authentication failed"
                        // Fallback to password authentication
                        self.authenticateWithPassword()
                    }
                }
            }
        } else {
            // Fallback to password authentication immediately
            authenticateWithPassword()
        }
    }
    
    private func authenticateWithPassword() {
        let context = LAContext()
        let reason = "Authenticate to access AppLock Pro"
        
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
            DispatchQueue.main.async {
                self.isCheckingAuth = false
                if success {
                    self.isAuthenticated = true
                    self.authError = nil
                } else {
                    self.authError = "Authentication failed"
                }
            }
        }
    }
}

struct AppRowView: View {
    let app: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "app.dashed")
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(app)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text("Protected with Touch ID")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "minus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
            .help("Remove protection")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// Custom button styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [.blue, .indigo],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(10)
            .shadow(color: .blue.opacity(0.3), radius: 6, x: 0, y: 3)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    let isDestructive: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(isDestructive ? .red : .blue)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isDestructive ? Color.red : Color.blue, lineWidth: 2)
            )
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Dark mode components
struct DarkAppRowView: View {
    let app: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "app.dashed")
                .font(.title2)
                .foregroundColor(.cyan)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(app)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text("Protected with Touch ID")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "minus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
            .help("Remove protection")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(red: 0.2, green: 0.2, blue: 0.25))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

// Dark mode button styles
struct DarkPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.black)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [.cyan, .blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(10)
            .shadow(color: .cyan.opacity(0.4), radius: 6, x: 0, y: 3)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct DarkSecondaryButtonStyle: ButtonStyle {
    let isDestructive: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(isDestructive ? .red : .cyan)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color(red: 0.2, green: 0.2, blue: 0.25))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isDestructive ? Color.red : Color.cyan, lineWidth: 2)
            )
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
