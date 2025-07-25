import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Image(systemName: "message")
                    Text("Chat")
                }
            
            DataAnalysisView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Analysis")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

struct SettingsView: View {
    @State private var serverStatus: String = "Checking..."
    @State private var isOnline: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    Text("Server Status")
                        .font(.headline)
                    
                    HStack {
                        Circle()
                            .fill(isOnline ? Color.green : Color.red)
                            .frame(width: 12, height: 12)
                        
                        Text(serverStatus)
                            .foregroundColor(isOnline ? .green : .red)
                    }
                    
                    Button("Check Status") {
                        checkServerStatus()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Settings")
            .onAppear {
                checkServerStatus()
            }
        }
    }
    
    private func checkServerStatus() {
        serverStatus = "Checking..."
        
        APIClient.healthCheck { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    serverStatus = "Online"
                    isOnline = true
                case .failure:
                    serverStatus = "Offline"
                    isOnline = false
                }
            }
        }
    }
}
