import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var auth: VKIDService
    @EnvironmentObject private var model: AppModel
    @State private var animateGlow = false

    var body: some View {
        ZStack {
            Brand.background.ignoresSafeArea()
            decorativeBackground

            ScrollView {
                VStack(spacing: 26) {
                    Spacer(minLength: 70)

                    BrandIconView(size: 112)
                        .shadow(color: Brand.accent.opacity(animateGlow ? 0.34 : 0.12), radius: animateGlow ? 35 : 14)

                    VStack(spacing: 10) {
                        BrandWordmark()
                        Text("Лёгкий независимый клиент")
                            .font(.headline)
                            .foregroundStyle(Brand.foreground)
                        Text("Лента, профиль, фото и видео в чистом тёмном интерфейсе.")
                            .font(.subheadline)
                            .foregroundStyle(Brand.subtle)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 310)
                    }

                    featureRow

                    VStack(spacing: 12) {
                        Button(action: auth.authorize) {
                            HStack {
                                if auth.state == .authorizing {
                                    ProgressView().tint(.black)
                                } else {
                                    Image(systemName: "person.crop.circle.badge.checkmark")
                                }
                                Text(auth.state == .authorizing ? "Открываем VK ID…" : "Войти через VK ID")
                                    .fontWeight(.bold)
                                Spacer()
                                Image(systemName: "arrow.right")
                            }
                            .foregroundStyle(.black)
                            .padding(.horizontal, 18)
                            .frame(height: 56)
                            .background(Brand.accent, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
                        }
                        .disabled(!auth.isConfigured || auth.state == .authorizing)
                        .opacity(auth.isConfigured ? 1 : 0.45)

                        Button {
                            model.enterDemoMode()
                        } label: {
                            Text("Открыть демонстрационный интерфейс")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Brand.foreground)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Brand.panel, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 17, style: .continuous)
                                        .stroke(Brand.border, lineWidth: 1)
                                }
                        }
                    }
                    .frame(maxWidth: 420)

                    statusCard
                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 22)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                animateGlow = true
            }
        }
    }

    private var decorativeBackground: some View {
        GeometryReader { proxy in
            ZStack {
                Circle()
                    .fill(Brand.accent.opacity(0.13))
                    .frame(width: proxy.size.width * 0.9)
                    .blur(radius: 85)
                    .offset(x: proxy.size.width * 0.35, y: -proxy.size.height * 0.28)

                Circle()
                    .stroke(Brand.accent.opacity(0.1), lineWidth: 1)
                    .frame(width: proxy.size.width * 1.05)
                    .offset(x: -proxy.size.width * 0.38, y: proxy.size.height * 0.35)
            }
        }
        .allowsHitTesting(false)
    }

    private var featureRow: some View {
        HStack(spacing: 8) {
            feature("bolt.fill", "Быстро")
            feature("rectangle.stack.fill", "Чистая лента")
            feature("lock.fill", "Keychain")
        }
    }

    private func feature(_ icon: String, _ title: String) -> some View {
        Label(title, systemImage: icon)
            .font(.caption.weight(.semibold))
            .foregroundStyle(Brand.subtle)
            .padding(.horizontal, 11)
            .padding(.vertical, 8)
            .background(Brand.panel.opacity(0.85), in: Capsule())
            .overlay { Capsule().stroke(Brand.border, lineWidth: 1) }
    }

    @ViewBuilder
    private var statusCard: some View {
        switch auth.state {
        case .needsConfiguration:
            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Нужны параметры VK ID", systemImage: "key.horizontal.fill")
                        .font(.headline)
                        .foregroundStyle(Brand.foreground)
                    Text("Добавьте GitHub Secrets VK_CLIENT_ID и VK_CLIENT_SECRET. До этого сборка работает в демонстрационном режиме.")
                        .font(.footnote)
                        .foregroundStyle(Brand.subtle)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: 420)
        case .failed(let message):
            ErrorBanner(message: message) {
                auth.configure()
            }
            .frame(maxWidth: 420)
        default:
            EmptyView()
        }
    }
}
