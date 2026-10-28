import Foundation
import SwiftUI

public enum AppConfig {
    public static let appName = "Jay Ho Gurudev"
    public static let appTagline = "Daily Saakhi & Spiritual Wisdom"
    public static let appVersion = "1.1.2"
    public static let buildNumber = "13"
    
    // Backend API Configuration
    public static let baseURL = "https://jayhogurudev.webnovatech.co.in"
    public static let apiKey = "jhg_a32ef879652f8763e5e0a0b573c9f48999077b38e133e649"
    
    // Website & Legal URLs
    public static let privacyURL = "\(baseURL)/privacy"
    public static let termsURL = "\(baseURL)/terms"
    public static let cookiesURL = "\(baseURL)/cookies"
    public static let developerURL = "https://webnovatech.co.in/"
    
    // Google Client ID (for OAuth parity)
    public static let googleWebClientID = "543071409732-36e9kg7ba73u1albhfms9b4gev90j2bm.apps.googleusercontent.com"
}
