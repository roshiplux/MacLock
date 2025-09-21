import SwiftUI
import LocalAuthentication

@main
struct AppLockApp: App {
    @StateObject private var appManager = AppLockManager()
    @State private var showingMainWindow = false
    
    var body: some Scene {
        // Main window - visible when needed
        WindowGroup {
            ContentView()
                .environmentObject(appManager)
                .frame(minWidth: 600, maxWidth: 600, minHeight: 700, maxHeight: 700)
                .onAppear {
                    // Set up app icon and configuration when view appears
                    createAppIcon()
                    
                    // Show in dock when main window appears
                    NSApp.setActivationPolicy(.regular)
                    
                    // Ensure window is proper size and centered
                    if let window = NSApp.keyWindow ?? NSApp.windows.first {
                        window.setFrame(NSRect(x: 0, y: 0, width: 600, height: 700), display: true)
                        window.center()
                        window.title = "Mac Lock - PluxCore Solutions"
                        
                        // Set window icon
                        if let appIcon = NSApp.applicationIconImage {
                            window.standardWindowButton(.documentIconButton)?.image = appIcon
                        }
                    }
                }
                .onDisappear {
                    // Hide from dock when window closes, keep menu bar
                    NSApp.setActivationPolicy(.accessory)
                }
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 600, height: 700)
        .commands {
            CommandGroup(replacing: .newItem) { }
            CommandGroup(replacing: .undoRedo) { }
            CommandGroup(replacing: .pasteboard) { }
        }
        
        // Menu bar controls - always visible
        MenuBarExtra("Mac Lock", image: "MenuBarIcon") {
            MenuBarView()
                .environmentObject(appManager)
        }
        .menuBarExtraStyle(.window)
    }
    
    private func createAppIcon() {
        // Create a high-quality app icon that works in all contexts
        let size = NSSize(width: 1024, height: 1024)
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        // Clear background
        NSColor.clear.setFill()
        NSRect(origin: .zero, size: size).fill()
        
        // Modern gradient background with rounded rectangle
        let backgroundRect = NSRect(x: 50, y: 50, width: 924, height: 924)
        let backgroundPath = NSBezierPath(roundedRect: backgroundRect, xRadius: 180, yRadius: 180)
        
        let gradient = NSGradient(colors: [
            NSColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0),  // Bright Blue
            NSColor(red: 0.36, green: 0.20, blue: 0.90, alpha: 1.0) // Purple
        ])
        gradient?.draw(in: backgroundPath, angle: 45)
        
        // Add subtle border
        NSColor.white.withAlphaComponent(0.2).setStroke()
        backgroundPath.lineWidth = 4
        backgroundPath.stroke()
        
        // Shield shape for lock icon with better design
        let shieldPath = NSBezierPath()
        let centerX: CGFloat = 512
        let centerY: CGFloat = 512
        let shieldWidth: CGFloat = 450
        let shieldHeight: CGFloat = 520
        
        shieldPath.move(to: NSPoint(x: centerX, y: centerY + shieldHeight/2))
        shieldPath.curve(to: NSPoint(x: centerX - shieldWidth/2, y: centerY + shieldHeight/4),
                        controlPoint1: NSPoint(x: centerX - shieldWidth/3, y: centerY + shieldHeight/2),
                        controlPoint2: NSPoint(x: centerX - shieldWidth/2, y: centerY + shieldHeight/3))
        shieldPath.line(to: NSPoint(x: centerX - shieldWidth/2, y: centerY - shieldHeight/4))
        shieldPath.curve(to: NSPoint(x: centerX, y: centerY - shieldHeight/2),
                        controlPoint1: NSPoint(x: centerX - shieldWidth/2, y: centerY - shieldHeight/3),
                        controlPoint2: NSPoint(x: centerX - shieldWidth/3, y: centerY - shieldHeight/2))
        shieldPath.curve(to: NSPoint(x: centerX + shieldWidth/2, y: centerY - shieldHeight/4),
                        controlPoint1: NSPoint(x: centerX + shieldWidth/3, y: centerY - shieldHeight/2),
                        controlPoint2: NSPoint(x: centerX + shieldWidth/2, y: centerY - shieldHeight/3))
        shieldPath.line(to: NSPoint(x: centerX + shieldWidth/2, y: centerY + shieldHeight/4))
        shieldPath.curve(to: NSPoint(x: centerX, y: centerY + shieldHeight/2),
                        controlPoint1: NSPoint(x: centerX + shieldWidth/2, y: centerY + shieldHeight/3),
                        controlPoint2: NSPoint(x: centerX + shieldWidth/3, y: centerY + shieldHeight/2))
        shieldPath.close()
        
        // Shield with gradient
        let shieldGradient = NSGradient(colors: [
            NSColor.white,
            NSColor(white: 0.9, alpha: 1.0)
        ])
        shieldGradient?.draw(in: shieldPath, angle: 90)
        
        // Shield border
        NSColor(white: 0.7, alpha: 1.0).setStroke()
        shieldPath.lineWidth = 3
        shieldPath.stroke()
        
        // Lock symbol inside shield with better proportions
        let lockWidth: CGFloat = 160
        let lockHeight: CGFloat = 180
        let lockX = centerX - lockWidth/2
        let lockY = centerY - lockHeight/2 + 40
        
        // Lock body with modern design
        let lockBody = NSBezierPath(roundedRect: NSRect(x: lockX + 25, y: lockY, width: 110, height: 100), xRadius: 12, yRadius: 12)
        NSColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0).setFill()
        lockBody.fill()
        
        // Lock body highlight
        NSColor.white.withAlphaComponent(0.3).setStroke()
        lockBody.lineWidth = 2
        lockBody.stroke()
        
        // Lock shackle with improved design
        let shackle = NSBezierPath()
        let shackleCenter = NSPoint(x: centerX, y: lockY + 80)
        shackle.appendArc(withCenter: shackleCenter, radius: 42, startAngle: 10, endAngle: 170)
        shackle.lineWidth = 18
        NSColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0).setStroke()
        shackle.stroke()
        
        // Inner shackle for depth
        let innerShackle = NSBezierPath()
        innerShackle.appendArc(withCenter: shackleCenter, radius: 42, startAngle: 10, endAngle: 170)
        innerShackle.lineWidth = 12
        NSColor(red: 0.0, green: 0.6, blue: 1.0, alpha: 1.0).setStroke()
        innerShackle.stroke()
        
        // Lock keyhole with better design
        let keyholeCircle = NSBezierPath(ovalIn: NSRect(x: centerX - 12, y: lockY + 35, width: 24, height: 24))
        NSColor.white.setFill()
        keyholeCircle.fill()
        
        // Keyhole slot
        let keyholeSlot = NSBezierPath(rect: NSRect(x: centerX - 4, y: lockY + 20, width: 8, height: 20))
        NSColor.white.setFill()
        keyholeSlot.fill()
        
        image.unlockFocus()
        
        // Create all standard icon sizes with proper scaling
        let iconSizes: [CGFloat] = [16, 32, 64, 128, 256, 512, 1024]
        for iconSize in iconSizes {
            let resizedImage = NSImage(size: NSSize(width: iconSize, height: iconSize))
            resizedImage.lockFocus()
            
            // Use high-quality scaling
            NSGraphicsContext.current?.imageInterpolation = .high
            image.draw(in: NSRect(x: 0, y: 0, width: iconSize, height: iconSize),
                      from: NSRect(x: 0, y: 0, width: 1024, height: 1024),
                      operation: .sourceOver,
                      fraction: 1.0)
            
            resizedImage.unlockFocus()
            
            if let rep = resizedImage.representations.first {
                image.addRepresentation(rep)
            }
        }
        
        // Set the app icon using multiple methods for maximum compatibility
        DispatchQueue.main.async {
            // Primary method
            NSApp.applicationIconImage = image
            
            // Secondary method - force dock update
            NSApp.dockTile.contentView = nil
            NSApp.dockTile.display()
            
            // Third method - set workspace icon
            let bundlePath = Bundle.main.bundlePath
            NSWorkspace.shared.setIcon(image, forFile: bundlePath)
        }
        
        // Also try to save the icon persistently
        self.saveIconToAppBundle(image)
    }
    
    private func saveIconToAppBundle(_ icon: NSImage) {
        let bundlePath = Bundle.main.bundlePath
        
        // Create Resources directory if needed
        let resourcesPath = "\(bundlePath)/Contents/Resources"
        try? FileManager.default.createDirectory(atPath: resourcesPath, withIntermediateDirectories: true, attributes: nil)
        
        // Save as multiple formats for compatibility
        let iconPaths = [
            "\(resourcesPath)/AppIcon.icns",
            "\(resourcesPath)/icon.icns",
            "\(resourcesPath)/MacLock.icns"
        ]
        
        for iconPath in iconPaths {
            if let tiffData = icon.tiffRepresentation,
               let bitmapRep = NSBitmapImageRep(data: tiffData),
               let pngData = bitmapRep.representation(using: .png, properties: [:]) {
                try? pngData.write(to: URL(fileURLWithPath: iconPath))
            }
        }
    }
}
