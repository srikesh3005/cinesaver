import SwiftUI
import AppKit
import AVFoundation

struct ContentView: View {
    @State private var statusMessage = "No video selected"
    @State private var isProcessing = false
    @State private var codecInfo = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("CineSaver")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text("🎬 Set any video as your macOS screensaver")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            // Video selection section
            VStack(alignment: .leading, spacing: 12) {
                Text("Video Selection")
                    .font(.system(size: 18, weight: .semibold))
                
                Text("Choose a local video file. It will be copied to a shared location accessible by the screensaver.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Button(action: chooseVideo) {
                    HStack {
                        Image(systemName: "film.fill")
                        Text("Choose Video File")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isProcessing)
            }
            
            Divider()
            
            // Status section
            VStack(alignment: .leading, spacing: 8) {
                Text("Status")
                    .font(.system(size: 18, weight: .semibold))
                
                HStack {
                    Image(systemName: getStatusIcon())
                        .foregroundStyle(getStatusColor())
                    
                    Text(statusMessage)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
            }
            
            Spacer()
            
            // Instructions
            VStack(alignment: .leading, spacing: 8) {
                Text("Quick Setup Guide")
                    .font(.system(size: 14, weight: .semibold))
                
                VStack(alignment: .leading, spacing: 4) {
                    InstructionRow(number: 1, text: "Choose a video above")
                    InstructionRow(number: 2, text: "Open System Settings → Screen Saver")
                    InstructionRow(number: 3, text: "Select 'CineSaver' from the list")
                    InstructionRow(number: 4, text: "Preview or set your screensaver!")
                }
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            }
            .padding(.top, 8)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            refreshStatus()
        }
    }
    
    private func getStatusIcon() -> String {
        if statusMessage.contains("Ready") || statusMessage.contains("Saved") {
            return "checkmark.circle.fill"
        } else if statusMessage.contains("failed") || statusMessage.contains("Error") {
            return "exclamationmark.triangle.fill"
        } else {
            return "info.circle.fill"
        }
    }
    
    private func getStatusColor() -> Color {
        if statusMessage.contains("Ready") || statusMessage.contains("Saved") {
            return .green
        } else if statusMessage.contains("failed") || statusMessage.contains("Error") {
            return .red
        } else {
            return .blue
        }
    }

    private func chooseVideo() {
        isProcessing = true
        
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.movie, .mpeg4Movie, .quickTimeMovie]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        guard panel.runModal() == .OK, let selectedURL = panel.url else {
            isProcessing = false
            return
        }

        Task {
            await copyVideo(from: selectedURL)
        }
    }
    
    private func copyVideo(from selectedURL: URL) async {
        do {
            // Get container URL and ensure directory exists
            guard let containerURL = SaverSettings.sharedContainerURL() else {
                await MainActor.run {
                    statusMessage = "❌ App Group container unavailable. Check App Group ID and signing."
                    isProcessing = false
                }
                return
            }
            
            // Create container directory if it doesn't exist
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: containerURL.path) {
                try fileManager.createDirectory(at: containerURL, withIntermediateDirectories: true, attributes: nil)
            }
            
            guard let destinationURL = SaverSettings.selectedVideoURL() else {
                await MainActor.run {
                    statusMessage = "❌ Could not create destination URL"
                    isProcessing = false
                }
                return
            }
            
            // Start accessing security-scoped resource
            let accessing = selectedURL.startAccessingSecurityScopedResource()
            defer {
                if accessing {
                    selectedURL.stopAccessingSecurityScopedResource()
                }
            }
            
            // Check if source file actually exists
            guard fileManager.fileExists(atPath: selectedURL.path) else {
                await MainActor.run {
                    statusMessage = "❌ Source video file not found at: \(selectedURL.path)"
                    isProcessing = false
                }
                return
            }
            
            // Remove existing file if present
            if fileManager.fileExists(atPath: destinationURL.path) {
                do {
                    // First try to change permissions if needed
                    try fileManager.setAttributes([.posixPermissions: 0o644], ofItemAtPath: destinationURL.path)
                    try fileManager.removeItem(at: destinationURL)
                } catch {
                    // If removal fails, try to force delete
                    let process = Process()
                    process.executableURL = URL(fileURLWithPath: "/bin/rm")
                    process.arguments = ["-f", destinationURL.path]
                    try? process.run()
                    process.waitUntilExit()
                    
                    // Check if file still exists
                    if fileManager.fileExists(atPath: destinationURL.path) {
                        throw NSError(domain: "CineSaver", code: -1, 
                                    userInfo: [NSLocalizedDescriptionKey: "Cannot remove old video file. Please delete it manually: \(destinationURL.path)"])
                    }
                }
            }
            
            // Copy the file
            try fileManager.copyItem(at: selectedURL, to: destinationURL)
            
            // Clear all extended attributes that might block access
            let clearAttrs = Process()
            clearAttrs.executableURL = URL(fileURLWithPath: "/usr/bin/xattr")
            clearAttrs.arguments = ["-c", destinationURL.path]
            try? clearAttrs.run()
            clearAttrs.waitUntilExit()
            
            // Set readable permissions on the new file
            try? fileManager.setAttributes([.posixPermissions: 0o644], ofItemAtPath: destinationURL.path)
            
            // Verify copy succeeded
            guard fileManager.fileExists(atPath: destinationURL.path) else {
                await MainActor.run {
                    statusMessage = "❌ Copy completed but file not found at destination"
                    isProcessing = false
                }
                return
            }

            UserDefaults.standard.set(true, forKey: SaverSettings.selectedVideoExistsKey)

            await MainActor.run {
                statusMessage = "✓ Saved: \(selectedURL.lastPathComponent)"
                isProcessing = false
            }
        } catch {
            let nsError = error as NSError
            await MainActor.run {
                statusMessage = "❌ Copy failed: \(error.localizedDescription) (Code: \(nsError.code))"
                isProcessing = false
            }
        }
    }

    private func refreshStatus() {
        guard let containerURL = SaverSettings.sharedContainerURL() else {
            statusMessage = "⚠️ Storage location unavailable"
            return
        }
        
        guard let selectedVideoURL = SaverSettings.selectedVideoURL() else {
            statusMessage = "⚠️ Cannot determine video path"
            return
        }

        if FileManager.default.fileExists(atPath: selectedVideoURL.path) {
            let fileSize = (try? FileManager.default.attributesOfItem(atPath: selectedVideoURL.path)[.size] as? UInt64) ?? 0
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file
            let sizeString = formatter.string(fromByteCount: Int64(fileSize))
            statusMessage = "✓ Ready: \(selectedVideoURL.lastPathComponent) (\(sizeString))"
        } else {
            // Check if container directory exists
            if FileManager.default.fileExists(atPath: containerURL.path) {
                statusMessage = "No video selected yet (Container ready at: \(containerURL.path))"
            } else {
                statusMessage = "No video selected (Container will be created when you choose a video)"
            }
        }
    }
}

// Helper view for instruction rows
struct InstructionRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Text("\(number).")
                .font(.system(size: 12, weight: .bold))
                .frame(width: 20)
            Text(text)
        }
    }
}
