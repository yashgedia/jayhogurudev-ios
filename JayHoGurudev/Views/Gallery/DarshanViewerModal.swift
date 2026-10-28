import SwiftUI

public struct DarshanViewerModal: View {
    let items: [DarshanItem]
    @State var selectedIndex: Int
    @Environment(\.dismiss) private var dismiss
    
    @State private var isSlideshowActive: Bool = false
    @State private var slideshowTimer: Timer?
    @State private var scale: CGFloat = 1.0
    
    public init(items: [DarshanItem], initialIndex: Int = 0, startSlideshow: Bool = false) {
        self.items = items
        self._selectedIndex = State(initialValue: initialIndex)
        self._isSlideshowActive = State(initialValue: startSlideshow)
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if !items.isEmpty {
                TabView(selection: $selectedIndex) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        ZStack {
                            AsyncImage(url: item.resolvedImageURL) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView().tint(.white)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .scaleEffect(scale)
                                        .gesture(
                                            MagnificationGesture()
                                                .onChanged { val in scale = val }
                                                .onEnded { _ in withAnimation { scale = 1.0 } }
                                        )
                                case .failure:
                                    VStack(spacing: 8) {
                                        Image(systemName: "photo.badge.exclamationmark")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white.opacity(0.6))
                                        Text("Divine Darshan loading...")
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            
            // Top Bar
            VStack {
                HStack {
                    Button(action: {
                        stopSlideshow()
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    
                    Spacer()
                    
                    if !items.isEmpty {
                        Text("\(selectedIndex + 1) / \(items.count)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Slideshow Toggle
                    Button(action: toggleSlideshow) {
                        HStack(spacing: 4) {
                            Image(systemName: isSlideshowActive ? "pause.fill" : "play.fill")
                            Text(isSlideshowActive ? "Pause" : "Slideshow")
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.spiritualSaffron)
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)
                
                Spacer()
                
                // Bottom Caption
                if !items.isEmpty && selectedIndex < items.count {
                    let item = items[selectedIndex]
                    VStack(spacing: 4) {
                        Text(item.title)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                        
                        if let desc = item.description, !desc.isEmpty {
                            Text(desc)
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.6))
                }
            }
        }
        .onAppear {
            if isSlideshowActive {
                startSlideshowTimer()
            }
        }
        .onDisappear {
            stopSlideshow()
        }
    }
    
    private func toggleSlideshow() {
        if isSlideshowActive {
            stopSlideshow()
        } else {
            isSlideshowActive = true
            startSlideshowTimer()
        }
    }
    
    private func startSlideshowTimer() {
        slideshowTimer?.invalidate()
        slideshowTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                selectedIndex = (selectedIndex + 1) % max(1, items.count)
            }
        }
    }
    
    private func stopSlideshow() {
        isSlideshowActive = false
        slideshowTimer?.invalidate()
        slideshowTimer = nil
    }
}
