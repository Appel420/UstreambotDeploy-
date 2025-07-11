import Foundation

class Configuration {
    static let shared = Configuration()
    
    private init() {}
    
    // MARK: - API Configuration
    var apiBaseURL: String {
        #if DEBUG
        return "https://your-dev-api.com/api/v1"
        #else
        return "https://your-prod-api.com/api/v1"
        #endif
    }
    
    var googleCloudProjectId: String {
        return Bundle.main.object(forInfoDictionaryKey: "GOOGLE_CLOUD_PROJECT_ID") as? String ?? ""
    }
    
    var appleAppId: String {
        return Bundle.main.object(forInfoDictionaryKey: "APPLE_APP_ID") as? String ?? ""
    }
    
    // MARK: - Feature Flags
    var isAnalyticsEnabled: Bool {
        #if DEBUG
        return false
        #else
        return true
        #endif
    }
    
    var isCrashReportingEnabled: Bool {
        #if DEBUG
        return false
        #else
        return true
        #endif
    }
}
