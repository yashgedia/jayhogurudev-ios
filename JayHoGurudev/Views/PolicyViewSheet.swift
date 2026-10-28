import SwiftUI

public enum PolicyTab: String, CaseIterable, Identifiable {
    case privacy = "Privacy"
    case terms = "Terms"
    case cookies = "Cookies"
    
    public var id: String { rawValue }
    
    public var title: String {
        switch self {
        case .privacy: return "Privacy Policy"
        case .terms: return "Terms of Service"
        case .cookies: return "Cookie Policy"
        }
    }
}

public struct PolicyViewSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State public var selectedTab: PolicyTab = .privacy
    
    public init(initialTab: PolicyTab = .privacy) {
        self._selectedTab = State(initialValue: initialTab)
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.spiritualCreamBg.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Segment Picker
                    Picker("Policy", selection: $selectedTab) {
                        ForEach(PolicyTab.allCases) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(selectedTab.title)
                                .font(.system(size: 22, weight: .bold, design: .serif))
                                .foregroundColor(Color.spiritualTextPrimary)
                            
                            Text("Devotee Protection & Trust Commitment")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.spiritualSaffronDark)
                            
                            Divider()
                                .background(Color.spiritualDivider)
                            
                            Text(policyBodyText(for: selectedTab))
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(Color.spiritualTextPrimary)
                                .lineSpacing(6)
                            
                            Spacer(minLength: 30)
                            
                            Link(destination: URL(string: externalURL(for: selectedTab))!) {
                                HStack {
                                    Image(systemName: "safari")
                                    Text("Open official web policy")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(Color.spiritualSaffronDark)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.spiritualSaffronLight)
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Legal & Policies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color.spiritualSaffronDark)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func externalURL(for tab: PolicyTab) -> String {
        switch tab {
        case .privacy: return AppConfig.privacyURL
        case .terms: return AppConfig.termsURL
        case .cookies: return AppConfig.cookiesURL
        }
    }
    
    private func policyBodyText(for tab: PolicyTab) -> String {
        switch tab {
        case .privacy:
            return """
            Jay Ho Gurudev Trust ("we", "our", or "us") is dedicated to protecting devotee privacy and ensuring transparency in all spiritual digital offerings.
            
            1. Information Collection:
            We collect devotee name, email address, username, and Jap mantra chant streaks to provide synchronization across your sacred devices.
            
            2. Audio & Media Access:
            When you listen to divine bhajans or meditate with guided breathing, audio is streamed securely. We do not access your private microphone without express interaction.
            
            3. Data Security:
            Your login credentials are encrypted using industry-standard protocols. We never sell, rent, or trade devotee spiritual records or personal identifiers to third parties.
            
            4. Account Deletion:
            Devotees may request permanent deletion of their account and all chanting streaks by visiting profile settings or contacting support@webnovatech.co.in.
            """
        case .terms:
            return """
            Welcome to the Jay Ho Gurudev devotee application. By using this platform, you agree to these devotional community guidelines:
            
            1. Sacred Purpose:
            This app is consecrated for spiritual enlightenment, daily Saakhi contemplation, community satsang, and digital Jap Mala chanting.
            
            2. Devotee Code of Conduct:
            Devotees must maintain respect in community feed comments. Hate speech, commercial spam, and disrespectful language are strictly prohibited.
            
            3. Spiritual Intellectual Property:
            All divine Saakhis, bhajans, photos, and spiritual recordings are published for sacred devotee welfare under the guidance of the Trust.
            """
        case .cookies:
            return """
            Our backend utilizes secure session tokens and local device caches to preserve:
            - Devotee authentication tokens
            - Daily Saakhi offline caching
            - Jap mala chant streak count
            - Bhajan playback queue preferences
            
            No tracking cookies are shared with advertising networks.
            """
        }
    }
}
