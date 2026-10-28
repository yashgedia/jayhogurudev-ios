import SwiftUI
import UIKit

public struct SaakhiShareCardView: View {
    let saakhi: Saakhi
    let quote: String?
    
    public init(saakhi: Saakhi, quote: String? = nil) {
        self.saakhi = saakhi
        self.quote = quote
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            // Header with Sacred Emblem
            VStack(spacing: 8) {
                Image("app_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.spiritualGold, lineWidth: 2))
                
                Text("Jay Ho Gurudev")
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(Color.spiritualTextPrimary)
                
                Text("દૈનિક સાખી અને પ્રેરક વચન 🙏")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.spiritualSaffronDark)
                
                if let d = saakhi.formattedDate ?? saakhi.date {
                    Text(d)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.spiritualTextSecondary)
                }
            }
            .padding(.top, 10)
            
            Divider().background(Color.spiritualDivider)
            
            // Sacred Gujarati Saakhi Content
            Text("\"\(saakhi.content)\"")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color.spiritualTextPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            
            if let q = quote, !q.isEmpty {
                Text(q)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.spiritualTextSecondary)
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Divider().background(Color.spiritualDivider)
            
            // Consecrated Footer
            VStack(spacing: 4) {
                Text("સત નામ સાહેબ • પાવન દિવ્ય સંદેશ")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color.spiritualSaffronDark)
                
                Text(AppConfig.baseURL)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color.spiritualTextSecondary)
            }
            .padding(.bottom, 12)
        }
        .padding(20)
        .frame(width: 360)
        .background(Color.spiritualCreamBg)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.spiritualGold, lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

public enum ShareSheetHelper {
    public static func shareTextAndImage(text: String, image: UIImage?, from viewController: UIViewController? = nil) {
        var items: [Any] = [text]
        if let img = image {
            items.append(img)
        }
        
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }
        
        let targetVC = viewController ?? rootVC
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = targetVC.view
            popover.sourceRect = CGRect(x: targetVC.view.bounds.midX, y: targetVC.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        targetVC.present(activityVC, animated: true)
    }
}
