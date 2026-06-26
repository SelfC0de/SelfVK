import SwiftUI

struct BrandWordmark: View {
    var compact = false

    var body: some View {
        HStack(spacing: compact ? 0 : 2) {
            Text("VK")
                .foregroundStyle(Brand.foreground)
            Text("SelfCode")
                .foregroundStyle(Brand.accent)
        }
        .font(compact ? .headline.weight(.bold) : .title2.weight(.bold))
        .tracking(-0.7)
        .accessibilityLabel("VK SelfCode")
    }
}

struct BrandIconView: View {
    var size: CGFloat = 72

    var body: some View {
        Image("BrandIcon")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                    .stroke(Brand.border, lineWidth: 1)
            }
    }
}

struct AvatarView: View {
    let url: URL?
    let name: String
    var size: CGFloat = 42
    var showsOnline = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    ZStack {
                        LinearGradient(
                            colors: [Brand.elevated, Brand.panel],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        Text(initials)
                            .font(.system(size: size * 0.3, weight: .bold))
                            .foregroundStyle(Brand.foreground)
                    }
                }
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay {
                Circle().stroke(Brand.border, lineWidth: 1)
            }

            if showsOnline {
                Circle()
                    .fill(Brand.accent)
                    .frame(width: size * 0.24, height: size * 0.24)
                    .overlay { Circle().stroke(Brand.background, lineWidth: 2) }
            }
        }
    }

    private var initials: String {
        name.split(separator: " ")
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()
            .uppercased()
    }
}

struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(14)
            .background(Brand.panel.opacity(0.94), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Brand.border, lineWidth: 1)
            }
    }
}

struct MetricLabel: View {
    let systemImage: String
    let value: Int
    var highlighted = false

    var body: some View {
        Label(value.formatted(), systemImage: systemImage)
            .font(.caption.weight(.medium))
            .foregroundStyle(highlighted ? Brand.accent : Brand.subtle)
            .labelStyle(.titleAndIcon)
    }
}

struct LoadingOverlay: View {
    let title: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
            VStack(spacing: 14) {
                ProgressView().tint(Brand.accent)
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Brand.foreground)
            }
            .padding(22)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
}

struct ErrorBanner: View {
    let message: String
    let retry: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Brand.accent)
            Text(message)
                .font(.footnote)
                .foregroundStyle(Brand.foreground)
                .lineLimit(3)
            Spacer(minLength: 8)
            if let retry {
                Button("Повторить", action: retry)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Brand.accent)
            }
        }
        .padding(12)
        .background(Brand.elevated, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Brand.border, lineWidth: 1)
        }
    }
}
