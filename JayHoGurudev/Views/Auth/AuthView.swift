import SwiftUI
import AuthenticationServices

public struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @State private var isRegisterMode: Bool = false
    @State private var fullName: String = ""
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    
    @State private var selectedPolicyTab: PolicyTab = .privacy
    @State private var showPolicySheet: Bool = false
    @State private var showGoogleConsentDialog: Bool = false
    @State private var googleEmailInput: String = ""
    @State private var googleNameInput: String = ""
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.spiritualCreamBg.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Logo & Devotional Title
                    VStack(spacing: 12) {
                        Image("app_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.spiritualGold, lineWidth: 2))
                            .shadow(color: Color.spiritualSaffron.opacity(0.3), radius: 10, x: 0, y: 5)
                            .padding(.top, 30)
                        
                        Text("Jay Ho Gurudev")
                            .font(.system(size: 26, weight: .bold, design: .serif))
                            .foregroundColor(Color.spiritualTextPrimary)
                        
                        Text(isRegisterMode ? "DEVOTEE REGISTRATION" : "DEVOTEE LOGIN")
                            .font(.system(size: 13, weight: .bold))
                            .tracking(2)
                            .foregroundColor(Color.spiritualSaffronDark)
                        
                        Text(isRegisterMode ?
                             "Create your devotee account to join chants, save streaks, and participate." :
                             "Sign in to sync your Jap streaks, community posts, and daily divine wisdom.")
                            .font(.system(size: 13))
                            .foregroundColor(Color.spiritualTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    
                    // Social Sign-in Options (Apple & Google)
                    VStack(spacing: 12) {
                        SignInWithAppleButton(
                            .signIn,
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: { result in
                                handleAppleSignIn(result: result)
                            }
                        )
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 50)
                        .cornerRadius(12)
                        
                        // Google Sign-In Button
                        Button(action: { showGoogleConsentDialog = true }) {
                            HStack(spacing: 12) {
                                Image(systemName: "g.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.red)
                                Text("Continue with Google")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color.spiritualTextPrimary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.spiritualDivider, lineWidth: 1.2)
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Divider
                    HStack {
                        VStack { Divider().background(Color.spiritualDivider) }
                        Text("or with email")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.spiritualTextSecondary)
                            .padding(.horizontal, 8)
                        VStack { Divider().background(Color.spiritualDivider) }
                    }
                    .padding(.horizontal, 28)
                    
                    // Input Card
                    VStack(spacing: 16) {
                        if isRegisterMode {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Full Name")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color.spiritualTextSecondary)
                                TextField("Enter your full name", text: $fullName)
                                    .padding()
                                    .background(Color.spiritualCreamBg)
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.spiritualDivider, lineWidth: 1))
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Username")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color.spiritualTextSecondary)
                                TextField("e.g. sant_bhakt", text: $username)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .padding()
                                    .background(Color.spiritualCreamBg)
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.spiritualDivider, lineWidth: 1))
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email Address")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color.spiritualTextSecondary)
                            TextField("Enter your email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding()
                                .background(Color.spiritualCreamBg)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.spiritualDivider, lineWidth: 1))
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color.spiritualTextSecondary)
                            HStack {
                                if showPassword {
                                    TextField("Enter password", text: $password)
                                } else {
                                    SecureField("Enter password", text: $password)
                                }
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .foregroundColor(Color.spiritualTextSecondary)
                                }
                            }
                            .padding()
                            .background(Color.spiritualCreamBg)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.spiritualDivider, lineWidth: 1))
                        }
                        
                        if let err = authManager.errorMessage {
                            Text(err)
                                .font(.system(size: 13))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.top, 4)
                        }
                        
                        // Submit Button
                        Button(action: handleEmailSubmit) {
                            HStack {
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text(isRegisterMode ? "Create Devotee Account" : "Sign In 🙏")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(SpiritualGradients.saffron)
                            .cornerRadius(12)
                            .shadow(color: Color.spiritualSaffron.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(authManager.isLoading)
                        .padding(.top, 8)
                        
                        // Toggle Mode Button
                        Button(action: {
                            withAnimation {
                                isRegisterMode.toggle()
                                authManager.errorMessage = nil
                            }
                        }) {
                            Text(isRegisterMode ? "Already registered? Sign In" : "New Devotee? Create an account")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.spiritualSaffronDark)
                        }
                        .padding(.top, 4)
                    }
                    .padding(20)
                    .spiritualCard(cornerRadius: 16)
                    .padding(.horizontal, 20)
                    
                    // Legal Policy Links
                    VStack(spacing: 8) {
                        Text("By proceeding, you agree to our")
                            .font(.system(size: 11))
                            .foregroundColor(Color.spiritualTextSecondary)
                        
                        HStack(spacing: 12) {
                            Button("Terms of Service") {
                                selectedPolicyTab = .terms
                                showPolicySheet = true
                            }
                            Text("•").foregroundColor(Color.spiritualDivider)
                            Button("Privacy Policy") {
                                selectedPolicyTab = .privacy
                                showPolicySheet = true
                            }
                            Text("•").foregroundColor(Color.spiritualDivider)
                            Button("Cookie Notice") {
                                selectedPolicyTab = .cookies
                                showPolicySheet = true
                            }
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.spiritualSaffronDark)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 30)
                }
            }
        }
        .sheet(isPresented: $showPolicySheet) {
            PolicyViewSheet(initialTab: selectedPolicyTab)
        }
        .sheet(isPresented: $authManager.needsUsernamePrompt) {
            UsernamePromptSheet()
        }
        .sheet(isPresented: $showGoogleConsentDialog) {
            googleConsentModalView
        }
    }
    
    // MARK: - Actions
    private func handleEmailSubmit() {
        hideKeyboard()
        Task {
            if isRegisterMode {
                guard !fullName.isEmpty, !email.isEmpty, !password.isEmpty else {
                    authManager.errorMessage = "Please fill in all devotee fields."
                    return
                }
                let uName = username.isEmpty ? "devotee_\(Int.random(in: 1000...9999))" : username
                _ = await authManager.register(fullName: fullName, username: uName, email: email, password: password)
            } else {
                guard !email.isEmpty, !password.isEmpty else {
                    authManager.errorMessage = "Please enter your email and password."
                    return
                }
                _ = await authManager.login(email: email, password: password)
            }
        }
    }
    
    private func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userIdentifier = appleIDCredential.user
                let email = appleIDCredential.email ?? "\(userIdentifier)@appleid.jhg"
                var name = "Devotee"
                if let given = appleIDCredential.fullName?.givenName {
                    name = given + (appleIDCredential.fullName?.familyName != nil ? " \(appleIDCredential.fullName!.familyName!)" : "")
                }
                
                Task {
                    _ = await authManager.authenticateSocial(email: email, name: name, socialId: userIdentifier)
                }
            }
        case .failure(let error):
            authManager.errorMessage = "Apple Sign In: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Google Devotee Sheet Modal
    private var googleConsentModalView: some View {
        NavigationView {
            ZStack {
                Color.spiritualCreamBg.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Image(systemName: "g.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                        .padding(.top, 20)
                    
                    Text("Devotee Google Account")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(Color.spiritualTextPrimary)
                    
                    Text("Enter your Google Account email to authenticate your devotee profile:")
                        .font(.system(size: 14))
                        .foregroundColor(Color.spiritualTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Your Devotee Name", text: $googleNameInput)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.spiritualDivider, lineWidth: 1))
                        
                        TextField("Your Google Email Address", text: $googleEmailInput)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.spiritualDivider, lineWidth: 1))
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        let email = googleEmailInput.trimmingCharacters(in: .whitespacesAndNewlines)
                        let name = googleNameInput.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !email.isEmpty else { return }
                        
                        showGoogleConsentDialog = false
                        Task {
                            let gId = "g_\(abs(email.hashValue))"
                            _ = await authManager.authenticateSocial(email: email, name: name.isEmpty ? "Devotee" : name, socialId: gId)
                        }
                    }) {
                        Text("Agree & Continue with Google")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(SpiritualGradients.saffron)
                            .cornerRadius(12)
                    }
                    .disabled(googleEmailInput.trimmingCharacters(in: .whitespaces).isEmpty)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showGoogleConsentDialog = false
                    }
                    .foregroundColor(Color.spiritualSaffronDark)
                }
            }
        }
    }
}
