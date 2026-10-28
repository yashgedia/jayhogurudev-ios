import Foundation
import SwiftUI
import AuthenticationServices

@MainActor
public class AuthManager: ObservableObject {
    public static let shared = AuthManager()
    
    @Published public var currentUser: User?
    @Published public var isLoggedIn: Bool = false
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var needsUsernamePrompt: Bool = false
    @Published public var pendingUserId: Int? = nil
    
    private let kUserId = "JHG_USER_ID"
    private let kUserToken = "JHG_USER_TOKEN"
    private let kUserName = "JHG_USER_NAME"
    private let kUserEmail = "JHG_USER_EMAIL"
    private let kUserUsername = "JHG_USER_USERNAME"
    
    private init() {
        restoreSession()
    }
    
    public func restoreSession() {
        let defaults = UserDefaults.standard
        let uid = defaults.integer(forKey: kUserId)
        let token = defaults.string(forKey: kUserToken)
        
        if uid > 0 && token != nil && !token!.isEmpty {
            let name = defaults.string(forKey: kUserName) ?? "Devotee"
            let email = defaults.string(forKey: kUserEmail) ?? ""
            let username = defaults.string(forKey: kUserUsername) ?? "devotee"
            
            self.currentUser = User(id: uid, fullName: name, username: username, email: email, avatar: nil, token: token)
            self.isLoggedIn = true
        } else {
            self.currentUser = nil
            self.isLoggedIn = false
        }
    }
    
    public func saveSession(id: Int, token: String, name: String, email: String, username: String) {
        let defaults = UserDefaults.standard
        defaults.set(id, forKey: kUserId)
        defaults.set(token, forKey: kUserToken)
        defaults.set(name, forKey: kUserName)
        defaults.set(email, forKey: kUserEmail)
        defaults.set(username, forKey: kUserUsername)
        
        self.currentUser = User(id: id, fullName: name, username: username, email: email, avatar: nil, token: token)
        self.isLoggedIn = true
        self.errorMessage = nil
    }
    
    // MARK: - Login
    public func login(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let url = URL(string: "\(AppConfig.baseURL)/api/v1/auth.php?action=login&api_key=\(AppConfig.apiKey)")!
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue(AppConfig.apiKey, forHTTPHeaderField: "X-API-KEY")
            
            let device = UIDevice.current.name
            let body: [String: Any] = [
                "email": email.trimmingCharacters(in: .whitespacesAndNewlines),
                "password": password,
                "device_name": "iOS \(device)"
            ]
            req.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (data, _) = try await URLSession.shared.data(for: req)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                errorMessage = "Invalid response from server"
                isLoading = false
                return false
            }
            
            if json["success"] as? Bool == true {
                let token = json["token"] as? String ?? UUID().uuidString
                let userObj = json["user"] as? [String: Any]
                let uid = userObj?["id"] as? Int ?? 1
                let name = userObj?["full_name"] as? String ?? email
                let uEmail = userObj?["email"] as? String ?? email
                let username = userObj?["username"] as? String ?? "devotee"
                
                saveSession(id: uid, token: token, name: name, email: uEmail, username: username)
                isLoading = false
                return true
            } else {
                errorMessage = json["message"] as? String ?? "Login failed"
                isLoading = false
                return false
            }
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    // MARK: - Register
    public func register(fullName: String, username: String, email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let url = URL(string: "\(AppConfig.baseURL)/api/v1/auth.php?action=register&api_key=\(AppConfig.apiKey)")!
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue(AppConfig.apiKey, forHTTPHeaderField: "X-API-KEY")
            
            let body: [String: Any] = [
                "full_name": fullName.trimmingCharacters(in: .whitespacesAndNewlines),
                "username": username.trimmingCharacters(in: .whitespacesAndNewlines),
                "email": email.trimmingCharacters(in: .whitespacesAndNewlines),
                "password": password
            ]
            req.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (data, _) = try await URLSession.shared.data(for: req)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                errorMessage = "Invalid server response"
                isLoading = false
                return false
            }
            
            if json["success"] as? Bool == true {
                let token = json["token"] as? String ?? UUID().uuidString
                let userObj = json["user"] as? [String: Any]
                let uid = userObj?["id"] as? Int ?? 1
                let name = userObj?["full_name"] as? String ?? fullName
                let uEmail = userObj?["email"] as? String ?? email
                let uName = userObj?["username"] as? String ?? username
                
                saveSession(id: uid, token: token, name: name, email: uEmail, username: uName)
                isLoading = false
                return true
            } else {
                errorMessage = json["message"] as? String ?? "Registration failed"
                isLoading = false
                return false
            }
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    // MARK: - Social Authentication (Apple / Google)
    public func authenticateSocial(email: String, name: String, socialId: String, avatar: String = "") async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let url = URL(string: "\(AppConfig.baseURL)/api/v1/auth.php?action=google&api_key=\(AppConfig.apiKey)")!
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue(AppConfig.apiKey, forHTTPHeaderField: "X-API-KEY")
            
            let body: [String: Any] = [
                "email": email,
                "name": name.isEmpty ? "Devotee" : name,
                "google_id": socialId,
                "avatar": avatar
            ]
            req.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (data, _) = try await URLSession.shared.data(for: req)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                errorMessage = "Invalid server response"
                isLoading = false
                return false
            }
            
            if json["success"] as? Bool == true {
                let token = json["token"] as? String ?? UUID().uuidString
                let userObj = json["user"] as? [String: Any]
                let uid = userObj?["id"] as? Int ?? 1
                let fullName = userObj?["full_name"] as? String ?? name
                let uEmail = userObj?["email"] as? String ?? email
                let username = userObj?["username"] as? String ?? ""
                
                saveSession(id: uid, token: token, name: fullName, email: uEmail, username: username)
                
                let isFirstTime = json["is_first_time"] as? Bool ?? false || json["needs_username"] as? Bool ?? false
                if isFirstTime || username.isEmpty {
                    self.pendingUserId = uid
                    self.needsUsernamePrompt = true
                }
                
                isLoading = false
                return true
            } else {
                errorMessage = json["message"] as? String ?? "Social sign-in failed"
                isLoading = false
                return false
            }
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    // MARK: - Set Username
    public func setUsername(userId: Int, username: String) async -> Bool {
        do {
            let url = URL(string: "\(AppConfig.baseURL)/api/v1/auth.php?action=set_username&api_key=\(AppConfig.apiKey)")!
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue(AppConfig.apiKey, forHTTPHeaderField: "X-API-KEY")
            
            let body: [String: Any] = [
                "user_id": userId,
                "username": username.trimmingCharacters(in: .whitespacesAndNewlines)
            ]
            req.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (data, _) = try await URLSession.shared.data(for: req)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { return false }
            
            if json["success"] as? Bool == true {
                UserDefaults.standard.set(username, forKey: kUserUsername)
                if var user = currentUser {
                    user.username = username
                    self.currentUser = user
                }
                self.needsUsernamePrompt = false
                return true
            }
            return false
        } catch {
            return false
        }
    }
    
    // MARK: - Change Password
    public func changePassword(oldPass: String, newPass: String) async -> (success: Bool, message: String) {
        guard let uid = currentUser?.id else {
            return (false, "Please sign in to change password.")
        }
        
        do {
            let url = URL(string: "\(AppConfig.baseURL)/api/v1/auth.php?action=change_password&api_key=\(AppConfig.apiKey)")!
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue(AppConfig.apiKey, forHTTPHeaderField: "X-API-KEY")
            
            let body: [String: Any] = [
                "user_id": uid,
                "old_password": oldPass,
                "new_password": newPass
            ]
            req.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (data, _) = try await URLSession.shared.data(for: req)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return (false, "Server response error.")
            }
            
            let success = json["success"] as? Bool ?? false
            let msg = json["message"] as? String ?? (success ? "Password changed successfully" : "Failed to change password")
            return (success, msg)
        } catch {
            return (false, error.localizedDescription)
        }
    }
    
    // MARK: - Logout
    public func logout() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: kUserId)
        defaults.removeObject(forKey: kUserToken)
        defaults.removeObject(forKey: kUserName)
        defaults.removeObject(forKey: kUserEmail)
        defaults.removeObject(forKey: kUserUsername)
        
        self.currentUser = nil
        self.isLoggedIn = false
        self.errorMessage = nil
    }
}
