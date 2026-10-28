# Jay Ho Gurudev — Native iOS Devotee Application 🪷

Official Native iOS Application for **Jay Ho Gurudev** (દૈનિક સાખી, માળા જાપ, ભજન, દર્શન અને સત્સંગ).
Built with modern **Swift 5.0** and **SwiftUI** for iOS 16.0+, offering 100% feature parity with the Android devotee application.

---

## 📱 Features & Highlights (1-to-1 Android Parity)

| Feature | Description |
| :--- | :--- |
| **Video Splash Screen** | Consecrated video introduction (`splashscreen.mp4`) with smooth fade-in, skip button, and fallback animated sacred lotus. |
| **Devotee Authentication** | Devotee sign-in, registration, native **Sign in with Apple**, and **Google Sign-In** with username setup sheet. |
| **Custom Elevated Jap Bar** | Bespoke bottom navigation bar featuring an elevated, glowing saffron center button for quick Jap Mala access. |
| **Daily Saakhi & Wisdom** | Daily Gujarati Saakhi, inspirational quote, "જય હો" reaction counter with haptic feedback, and blessing card sharing. |
| **Sacred Saakhi Book** | Archive of past Saakhis and spiritual reflections. |
| **Digital Jap Mala Counter** | Sacred bead counter tracking 108 beads per mala, concentric glowing progress ring, vibration/haptics on each bead, celebratory 108 milestone banner, and debounced auto-sync to backend. |
| **Divine Bhajans & Player** | Audio streaming with background playback capability (`AVAudioSession`), lock-screen `MPNowPlayingInfoCenter` / Control Center controls, persistent mini-player bar, and full-screen spinning disc player sheet. |
| **Guided Pranayama & Meditation** | 4-4-4-2 breathing cycle (Inhale 4s -> Hold 4s -> Exhale 4s -> Rest 2s) with pulsing halo animation, Sanskrit mantra guidance, haptic phase cues, and background ambient **Om Chant** loop (`om_chant.wav`). |
| **Sacred Darshan Gallery** | 2-column adaptive photo grid categorized by Ashram / Vigraha, pinch-to-zoom full-screen viewer, and auto-cycling sacred slideshow. |
| **Community Satsang Feed** | Devotee community posts, images, likes ("જય હો"), full comments sheet with real-time commenting, and sharing. |
| **Upcoming Satsang Events** | Event date badges, descriptions, ashram/venue locations, and one-tap "I am Going / Attending" RSVP counter. |
| **Temple Broadcasts** | In-app notification bell with real-time polling of temple announcements, badges, and local system notifications. |
| **Devotee Profile & Security** | Chanting streaks, rank, password change modal, legal policies (Privacy Policy, Terms of Service, Cookies) compliant with Apple App Store guidelines. |

---

## 🛠 Project Structure

```
ios-app/
├── JayHoGurudev.xcodeproj/          # Xcode Project file
│   └── project.pbxproj             # PBX configuration with all build targets & frameworks
├── JayHoGurudev/
│   ├── JayHoGurudevApp.swift       # @main App entry point & spiritual navigation bar styling
│   ├── Info.plist                  # Background audio modes, permissions, and app config
│   ├── Config/
│   │   └── AppConfig.swift         # Backend URL, API Key, legal URLs, and app metadata
│   ├── Theme/
│   │   └── SpiritualTheme.swift    # Saffron, Gold, and Cream devotional palette & modifiers
│   ├── Models/
│   │   └── Models.swift            # User, Saakhi, BhajanTrack, Event, PostItem, etc.
│   ├── Services/
│   │   ├── APIService.swift        # Unified async networking to /api/v1/ endpoints
│   │   ├── AuthManager.swift       # Devotee session management & persistence
│   │   ├── SpiritualAudioManager.swift # AVPlayer background audio & lock screen controls
│   │   ├── MeditationAudioService.swift # Looping Om chant ambient audio manager
│   │   ├── HapticManager.swift     # Light bead tap & 108 milestone haptics
│   │   └── BroadcastPoller.swift   # Temple notices polling & local notifications
│   ├── Views/
│   │   ├── Splash/SplashView.swift
│   │   ├── Auth/AuthView.swift & UsernamePromptSheet.swift
│   │   ├── Main/MainTabView.swift & MiniPlayerBarView.swift
│   │   ├── Home/HomeView.swift, SaakhiBookSheet.swift, SaakhiShareCardView.swift
│   │   ├── Feed/FeedView.swift & CommentsSheet.swift
│   │   ├── Jap/JapView.swift
│   │   ├── Events/EventsView.swift
│   │   ├── Profile/ProfileView.swift & ChangePasswordSheet.swift
│   │   ├── Bhajans/BhajansView.swift & FullPlayerSheet.swift
│   │   ├── Meditation/MeditationView.swift
│   │   ├── Gallery/GalleryView.swift & DarshanViewerModal.swift
│   │   ├── Notices/NoticesSheet.swift
│   │   └── Legal/PolicyViewSheet.swift
│   ├── Resources/
│   │   ├── splashscreen.mp4        # Video splash asset
│   │   └── om_chant.wav            # Consecrated Om chant audio loop
│   └── Assets.xcassets/            # App icons, splash, and sacred logo assets
└── .github/workflows/
    └── ios-build.yml               # Automated CI/CD for building on macOS runners
```

---

## 🚀 How to Run the App

### Requirements
- **macOS Sonoma / Sequoia** with **Xcode 15+** installed (or automated GitHub Actions)
- iOS 16.0+ deployment target (compatible with iPhone and iPad)

### Running in Xcode
1. Open `ios-app/JayHoGurudev.xcodeproj` in Xcode.
2. Select your target simulator (e.g., **iPhone 15 Pro** or **iPhone 16**).
3. Press **Cmd + R** to Build & Run.
4. The video splash screen will play, followed by the devotee authentication / main sanctuary!

### Building with Command Line
```bash
cd ios-app
xcodebuild clean build \
  -project JayHoGurudev.xcodeproj \
  -scheme JayHoGurudev \
  -destination "platform=iOS Simulator,name=iPhone 15,OS=latest"
```

### Distributing to App Store / TestFlight
1. In Xcode, navigate to `Signing & Capabilities`.
2. Select your **Apple Developer Team**.
3. Select `Product` > `Archive`.
4. Click **Distribute App** to upload directly to **App Store Connect / TestFlight**.
