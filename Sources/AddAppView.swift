import SwiftUI
import UniformTypeIdentifiers

struct AddAppView: View {
    @EnvironmentObject var appManager: AppLockManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedAppPath: String = ""
    @State private var showingFilePicker = false
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Add Application to Lock")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Selected App:")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text(selectedAppPath.isEmpty ? "No app selected" : URL(fileURLWithPath: selectedAppPath).lastPathComponent)
                            .foregroundColor(selectedAppPath.isEmpty ? .gray : .white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(red: 0.15, green: 0.15, blue: 0.2))
                            .cornerRadius(8)
                        
                        Button("Browse") {
                            showingFilePicker = true
                        }
                        .buttonStyle(.bordered)
                        .tint(.cyan)
                    }
                }
                
                HStack(spacing: 15) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .tint(.gray)
                    
                    Button("Add App") {
                        if !selectedAppPath.isEmpty {
                            let appName = URL(fileURLWithPath: selectedAppPath).lastPathComponent
                            appManager.addApp(appName)
                            dismiss()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.cyan)
                    .disabled(selectedAppPath.isEmpty)
                }
            }
            .padding()
        }
        .preferredColorScheme(.dark)
        .frame(width: 400, height: 200)
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.application],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    selectedAppPath = url.path
                }
            case .failure(let error):
                print("Error selecting file: \(error)")
            }
        }
    }
}
