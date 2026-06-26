import SwiftUI

struct FeedView: View {
    @EnvironmentObject private var auth: VKIDService
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationStack {
            ZStack {
                Brand.background.ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 14) {
                        header
                        stories

                        if let error = model.errorMessage {
                            ErrorBanner(message: error) {
                                Task { await model.refresh(using: auth) }
                            }
                            .padding(.horizontal, 14)
                        }

                        ForEach(model.feed) { item in
                            NavigationLink {
                                PostDetailView(item: item)
                            } label: {
                                PostCardView(item: item)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 12)
                        }
                    }
                    .padding(.bottom, 24)
                }
                .refreshable {
                    await model.refresh(using: auth)
                }

                if model.isLoading && model.feed.isEmpty {
                    LoadingOverlay(title: "Загружаем ленту")
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            Button(action: {}) {
                Image(systemName: "line.3.horizontal")
                    .font(.headline)
                    .foregroundStyle(Brand.foreground)
                    .frame(width: 38, height: 38)
                    .background(Brand.panel, in: Circle())
            }

            BrandWordmark(compact: true)
            Spacer()

            Button(action: {}) {
                Image(systemName: "magnifyingglass")
                    .font(.headline)
                    .foregroundStyle(Brand.foreground)
                    .frame(width: 38, height: 38)
                    .background(Brand.panel, in: Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }

    private var stories: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                storyAvatar(
                    name: "Вы",
                    url: model.profile.avatarURL,
                    isCurrent: true
                )

                ForEach(Array(uniqueAuthors.prefix(8)), id: \.id) { author in
                    storyAvatar(name: author.name, url: author.avatarURL, isCurrent: false)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }

    private var uniqueAuthors: [FeedAuthor] {
        var seen = Set<Int>()
        return model.feed.compactMap { item in
            guard seen.insert(item.author.id).inserted else { return nil }
            return item.author
        }
    }

    private func storyAvatar(name: String, url: URL?, isCurrent: Bool) -> some View {
        VStack(spacing: 6) {
            ZStack(alignment: .bottomTrailing) {
                AvatarView(url: url, name: name, size: 58, showsOnline: !isCurrent)
                    .padding(3)
                    .overlay {
                        Circle().stroke(Brand.accent, lineWidth: 2)
                    }

                if isCurrent {
                    Image(systemName: "plus")
                        .font(.caption.bold())
                        .foregroundStyle(.black)
                        .frame(width: 20, height: 20)
                        .background(Brand.accent, in: Circle())
                        .overlay { Circle().stroke(Brand.background, lineWidth: 2) }
                }
            }

            Text(name.split(separator: " ").first.map(String.init) ?? name)
                .font(.caption2)
                .foregroundStyle(Brand.subtle)
                .lineLimit(1)
                .frame(width: 64)
        }
    }
}
