import SwiftUI

/// Deterministic avatar color and initials for a player.
enum PlayerAvatarStyle {
    private static let palette: [Color] = [
        Color(uiColor: .systemBlue),
        Color(uiColor: .systemGreen),
        Color(uiColor: .systemOrange),
        Color(uiColor: .systemPurple),
        Color(uiColor: .systemTeal),
        Color(uiColor: .systemIndigo),
        Color(uiColor: .systemPink),
        Color(uiColor: .systemBrown)
    ]

    static func backgroundColor(seed: String) -> Color {
        let hash = abs(seed.hashValue)
        return palette[hash % palette.count]
    }

    static func initials(for name: String) -> String {
        let parts = name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: " ")
            .filter { !$0.isEmpty }

        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}

/// Circular initials avatar for player identity.
struct PlayerAvatarView: View {
    enum Size {
        case small
        case large

        var dimension: CGFloat {
            switch self {
            case .small: return 36
            case .large: return 72
            }
        }

        var font: Font {
            switch self {
            case .small: return .caption.weight(.bold)
            case .large: return .title2.weight(.bold)
            }
        }
    }

    let name: String
    var playerId: String?
    var size: Size = .small

    private var seed: String { playerId ?? name }

    var body: some View {
        Text(PlayerAvatarStyle.initials(for: name))
            .font(size.font)
            .foregroundStyle(.white)
            .frame(width: size.dimension, height: size.dimension)
            .background(PlayerAvatarStyle.backgroundColor(seed: seed), in: Circle())
            .accessibilityLabel("\(name) avatar")
    }
}

#Preview {
    HStack(spacing: 16) {
        PlayerAvatarView(name: "Alex Johnson", playerId: "1")
        PlayerAvatarView(name: "Bob", playerId: "2", size: .large)
    }
    .padding()
}
