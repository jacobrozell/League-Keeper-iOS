import SwiftUI

/// App crest mark — trophy on gold field, shared by splash and onboarding.
struct BrandCrest: View {
    @Environment(\.palette) private var palette
    var size: CGFloat = 160

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: palette.gold),
                            Color(hex: palette.goldBright),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Image(systemName: "trophy.fill")
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(Color(hex: palette.crestText))
                .symbolRenderingMode(.monochrome)
        }
        .frame(width: size, height: size)
        .shadow(color: .black.opacity(0.14), radius: size * 0.06, y: size * 0.03)
        .accessibilityLabel("\(AppInfo.displayName) crest")
    }
}

#Preview {
    ZStack {
        Color("LaunchBackground").ignoresSafeArea()
        BrandCrest()
    }
}
