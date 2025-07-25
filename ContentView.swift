import SwiftUI
import AVKit
import os.log

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var chatViewModel = ChatViewModel()
    @StateObject private var videoViewModel = VideoViewModel()
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Status Bar
                StatusBarView()
                    .environmentObject(appState)
                
                // Video Player Section
                VideoPlayerSection()
                    .environmentObject(videoViewModel)
                
                // Chat Section
                ChatSection()
                    .environmentObject(chatViewModel)
            }
            .navigationTitle("DevAssist 4.2.0")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Settings") {
                        showingSettings = true
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(appState)
            }
        }
        .onAppear {
            Task {
                await chatViewModel.initialize()
                await videoViewModel.initialize()
            }
        }
    }
}

// MARK: - Status Bar Component
struct StatusBarView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack {
            // Network Status
            HStack(spacing: 4) {
                Circle()
                    .fill(networkStatusColor)
                    .frame(width: 8, height: 8)
                Text(networkStatusText)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // API Health
            HStack(spacing: 4) {
                Image(systemName: apiHealthIcon)
                    .foregroundColor(apiHealthColor)
                    .font(.caption)
                Text("API")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .background(Color(UIColor.systemGray6))
    }
    
    private var networkStatusColor: Color {
        switch appState.networkStatus {
        case .connected: return .green
        case .disconnected: return .red
        case .unknown: return .orange
        }
    }
    
    private var networkStatusText: String {
        switch appState.networkStatus {
        case .connected: return "Online"
        case .disconnected: return "Offline"
        case .unknown: return "Checking"
        }
    }
    
    private var apiHealthIcon: String {
        switch appState.apiHealth {
        case .healthy: return "checkmark.circle.fill"
        case .unhealthy: return "xmark.circle.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }
    
    private var apiHealthColor: Color {
        switch appState.apiHealth {
        case .healthy: return .green
        case .unhealthy: return .red
        case .unknown: return .orange
        }
    }
}

// MARK: - Video Player Section
struct VideoPlayerSection: View {
    @EnvironmentObject var videoViewModel: VideoViewModel
    
    var body: some View {
        VStack {
            if let player = videoViewModel.player {
                VideoPlayer(player: player)
                    .frame(height: 220)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .onAppear {
                        videoViewModel.configureAudioSession()
                    }
                    .onDisappear {
                        videoViewModel.pausePlayback()
                    }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 220)
                    .overlay(
                        VStack {
                            ProgressView()
                            Text("Loading video...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    )
                    .padding(.horizontal)
            }
        }
    }
}

// MARK: - Chat Section
struct ChatSection: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    @State private var messageText = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(chatViewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                        
                        if chatViewModel.isLoading {
                            TypingIndicator()
                        }
                    }
                    .padding()
                }
                .onChange(of: chatViewModel.messages.count) { _ in
                    if let lastMessage = chatViewModel.messages.last {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input Section
            VStack {
                Divider()
                
                HStack(spacing: 12) {
                    TextField("Type your message...", text: $messageText, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isTextFieldFocused)
                        .lineLimit(1...4)
                        .onSubmit {
                            sendMessage()
                        }
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(messageText.isEmpty ? .gray : .blue)
                    }
                    .disabled(messageText.isEmpty || chatViewModel.isLoading)
                }
                .padding()
            }
            .background(Color(UIColor.systemBackground))
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let message = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        messageText = ""
        isTextFieldFocused = false
        
        Task {
            await chatViewModel.sendMessage(message)
        }
    }
}

// MARK: - Message Bubble Component
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 50)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.text)
                        .padding(12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.text)
                        .padding(12)
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer(minLength: 50)
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    @State private var animationPhase = 0
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .scaleEffect(animationPhase == index ? 1.2 : 0.8)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: animationPhase
                        )
                }
            }
            .padding(12)
            .background(Color(UIColor.systemGray5))
            .cornerRadius(16)
            
            Spacer()
        }
        .onAppear {
            animationPhase = 0
        }
    }
}
