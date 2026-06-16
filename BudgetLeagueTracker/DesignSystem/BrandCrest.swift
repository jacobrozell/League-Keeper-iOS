import SwiftUI

/// App crest mark — shared by launch screen, splash, and settings.
struct BrandCrest: View {
    enum ClipStyle {
        /// iOS-style squircle — settings and other list contexts.
        case roundedRect
        /// Fills a circular frame — splash and onboarding hero.
        case circle
    }

    var size: CGFloat = 160
    var showsShadow: Bool = true
    var clipStyle: ClipStyle = .roundedRect

    var body: some View {
        let image = Image("CrestLogo")
            .resizable()
            .aspectRatio(contentMode: clipStyle == .circle ? .fill : .fit)
            .frame(width: size, height: size)

        Group {
            switch clipStyle {
            case .roundedRect:
                image.clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
            case .circle:
                image.clipShape(Circle())
            }
        }
        .shadow(
            color: showsShadow ? .black.opacity(0.14) : .clear,
            radius: showsShadow ? size * 0.06 : 0,
            y: showsShadow ? size * 0.03 : 0
        )
        .accessibilityLabel("\(AppInfo.displayName) crest")
    }
}

#Preview {
    ZStack {
        Color("LaunchBackground").ignoresSafeArea()
        BrandCrest()
    }
}
