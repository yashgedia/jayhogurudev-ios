import SwiftUI

public struct UsernamePromptSheet: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var usernameInput: String = ""
    @State private var isSubmitting: Bool = false
    @State private var errorText: String? = nil
    
    public var body: some View {
        ZStack {
            Color.spiritualCreamBg.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header Icon
                ZStack {
                    Circle()
                        .fill(Color.spiritualSaffronLight)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "at")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color.spiritualSaffronDark)
                }
                .padding(.top, 24)
                
                VStack(spacing: 8) {
                    Text("Choose Your Devotee Username")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(Color.spiritualTextPrimary)
                    
                    Text("This unique spiritual handle will represent you on the Jap Mala Leaderboard and community Satsang feed.")
                        .font(.system(size: 14))
                        .foregroundColor(Color.spiritualTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Text Field
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("@")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.spiritualSaffronDark)
                        
                        TextField("e.g. sant_bhakt", text: $usernameInput)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .font(.system(size: 16))
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.spiritualDivider, lineWidth: 1)
                    )
                    
                    if let err = errorText {
                        Text(err)
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal)
                
                // Submit Button
                Button(action: submitUsername) {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Confirm & Enter Sanctuary")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(SpiritualGradients.saffron)
                    .cornerRadius(14)
                    .shadow(color: Color.spiritualSaffron.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(isSubmitting || usernameInput.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func submitUsername() {
        let clean = usernameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard clean.count >= 3 else {
            errorText = "Username must be at least 3 characters long."
            return
        }
        guard let uid = authManager.pendingUserId else {
            authManager.needsUsernamePrompt = false
            return
        }
        
        isSubmitting = true
        errorText = nil
        
        Task {
            let success = await authManager.setUsername(userId: uid, username: clean)
            isSubmitting = false
            if !success {
                errorText = "This username is taken or unavailable. Please try another."
            }
        }
    }
}
