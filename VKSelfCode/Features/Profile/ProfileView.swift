import Foundation
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    cover
                    identity
                        .padding(.horizontal, 16)
                        .offset(y: -42)

                    VStack(spacing: 16) {
                        stats
                        actions
                        about
                        recentPosts
                    }
                    .padding(.horizontal, 16)
                    .offset(y: -24)
                }
            }
            .background(Brand.background)
            .ignoresSafeArea(edges: .top)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var cover: some View {
        ZStack {
            LinearGradient(
                colors: [Brand.accent.opacity(0.55), Brand.background, Brand.panel],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .frame(height: 230)

            Circle()
                .stroke(Brand.accent.opacity(0.18), lineWidth: 1)
                .frame(width: 280, height: 280)
                .offset(x: 130, y: -70)

            VStack {
                HStack {
                    BrandWordmark(compact: true)
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(Brand.foreground)
                            .frame(width: 40, height: 40)
                            .background(.black.opacity(0.35), in: Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 58)
                Spacer()
            }
        }
    }

    private var identity: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .bottom) {
                AvatarView(
                    url: model.profile.avatarURL,
                    name: model.profile.fullName,
                    size: 92,
                    showsOnline: model.profile.online == 1
                )
                .padding(4)
                .background(Brand.background, in: Circle())

                Spacer()

                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(Brand.foreground)
                        .frame(width: 42, height: 42)
                        .background(Brand.panel, in: Circle())
                }
            }

            HStack(spacing: 6) {
                Text(model.profile.fullName)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Brand.foreground)
                if model.profile.verified == 1 {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(Brand.accent)
                }
            }

            Text(model.profile.domain.map { "@\($0)" } ?? "id\(model.profile.id)")
                .font(.subheadline)
                .foregroundStyle(Brand.subtle)

            if let status = model.profile.status, !status.isEmpty {
                Text(status)
                    .font(.subheadline)
                    .foregroundStyle(Brand.foreground)
            }

            if let city = model.profile.city?.title {
                Label(city, systemImage: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundStyle(Brand.subtle)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var stats: some View {
        HStack {
            stat(model.profile.counters?.posts ?? model.feed.count, "Публикации")
            Divider().frame(height: 32).overlay(Brand.border)
            stat(model.profile.counters?.followers ?? 0, "Подписчики")
            Divider().frame(height: 32).overlay(Brand.border)
            stat(model.profile.counters?.friends ?? 0, "Друзья")
        }
        .padding(.vertical, 14)
        .background(Brand.panel, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Brand.border, lineWidth: 1)
        }
    }

    private func stat(_ value: Int, _ title: String) -> some View {
        VStack(spacing: 3) {
            Text(value.formatted(.number.notation(.compactName)))
                .font(.headline.weight(.bold))
                .foregroundStyle(Brand.foreground)
            Text(title)
                .font(.caption2)
                .foregroundStyle(Brand.subtle)
        }
        .frame(maxWidth: .infinity)
    }

    private var actions: some View {
        HStack(spacing: 10) {
            Button("Редактировать") {}
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(Brand.accent, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            Button("Сообщение") {}
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Brand.foreground)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(Brand.panel, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Brand.border, lineWidth: 1)
                }
        }
    }

    private var about: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("О профиле")
                    .font(.headline)
                    .foregroundStyle(Brand.foreground)

                Label("Независимый клиент VK на SwiftUI", systemImage: "swift")
                Label("Собирается через GitHub Actions", systemImage: "hammer.fill")
                Label("Сессия хранится в Keychain", systemImage: "lock.shield.fill")
            }
            .font(.subheadline)
            .foregroundStyle(Brand.subtle)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var recentPosts: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Последние публикации")
                .font(.headline)
                .foregroundStyle(Brand.foreground)

            ForEach(Array(model.feed.prefix(3))) { item in
                PostCardView(item: item)
            }
        }
    }
}
