import SwiftUI

public struct ChangePasswordSheet: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String? = nil
    @State private var successMessage: String? = nil
    @State private var isSubmitting: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.spiritualCreamBg.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Current Password")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.spiritualTextSecondary)
                        SecureField("Enter your existing password", text: $currentPassword)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.spiritualDivider, lineWidth: 1))
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("New Password")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.spiritualTextSecondary)
                        SecureField("Enter new spiritual password", text: $newPassword)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.spiritualDivider, lineWidth: 1))
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Confirm New Password")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.spiritualTextSecondary)
                        SecureField("Re-enter new password", text: $confirmPassword)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.spiritualDivider, lineWidth: 1))
                    }
                    
                    if let err = errorMessage {
                        Text(err)
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                    }
                    
                    if let succ = successMessage {
                        Text(succ)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color.spiritualEmerald)
                    }
                    
                    Button(action: submitPasswordChange) {
                        HStack {
                            if isSubmitting {
                                ProgressView().tint(.white)
                            } else {
                                Text("Update Password")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(SpiritualGradients.saffron)
                        .cornerRadius(12)
                    }
                    .disabled(isSubmitting)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color.spiritualSaffronDark)
                }
            }
        }
    }
    
    private func submitPasswordChange() {
        errorMessage = nil
        successMessage = nil
        
        guard !currentPassword.isEmpty, !newPassword.isEmpty else {
            errorMessage = "Please fill in all password fields."
            return
        }
        guard newPassword == confirmPassword else {
            errorMessage = "New passwords do not match."
            return
        }
        guard newPassword.count >= 6 else {
            errorMessage = "New password must be at least 6 characters long."
            return
        }
        
        isSubmitting = true
        Task {
            let res = await authManager.changePassword(oldPass: currentPassword, newPass: newPassword)
            isSubmitting = false
            if res.success {
                successMessage = "Password updated successfully! 🙏"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    dismiss()
                }
            } else {
                errorMessage = res.message
            }
        }
    }
}
