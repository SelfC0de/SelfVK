import SwiftUI

struct FeedView: View {
    @EnvironmentObject private var auth: VKIDService
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationStack {
            ZStack {
                Brand.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    header

                    ScrollView {
                        LazyVStack(spacing: 14) {
                            stories
                                .padding(.top, 4)

                            if let error = model.errorMessage {
                                ErrorBanner(message: error) {
                                    Task {
                                        await model.refresh(using: auth)
                                    }
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
                                .padding(.horizontal, 14)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 18)
                    }
                    .scrollIndicators(.hidden)
                    .refreshable {
                        await model.refresh(using: auth)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if model.isLoading && model.feed.isEmpty {
                    LoadingOverlay(title: "Загружаем ленту")
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        ZStack {
            HStack {
                roundButton(systemImage: "line.3.horizontal") {
                    // Меню будет подключено отдельным этапом.
                }

                Spacer()

                roundButton(systemImage: "magnifyingglass") {
                    // Поиск будет подключён отдельным этапом.
                }
            }

            BrandWordmark(compact: true)
        }
        .frame(height: 52)
        .padding(.horizontal, 16)
        .padding(.top, 2)
        .padding(.bottom, 6)
        .background {
            Brand.background
                .opacity(0.97)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Brand.border.opacity(0.65))
                .frame(height: 1)
        }
    }

    private func roundButton(
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(Brand.foreground)
                .frame(width: 42, height: 42)
                .background(
                    Brand.panel,
                    in: Circle()
                )
                .overlay {
                    Circle()
                        .stroke(Brand.border, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
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
                    storyAvatar(
                        name: author.name,
                        url: author.avatarURL,
                        isCurrent: false
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
    }

    private var uniqueAuthors: [FeedAuthor] {
        var seen = Set<Int>()

        return model.feed.compactMap { item in
            guard seen.insert(item.author.id).inserted else {
                return nil
            }

            return item.author
        }
    }

    private func storyAvatar(
        name: String,
        url: URL?,
        isCurrent: Bool
    ) -> some View {
        VStack(spacing: 7) {
            ZStack(alignment: .bottomTrailing) {
                AvatarView(
                    url: url,
                    name: name,
                    size: 64,
                    showsOnline: !isCurrent
                )
                .padding(3)
                .overlay {
                    Circle()
                        .stroke(Brand.accent, lineWidth: 2.4)
                }

                if isCurrent {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(width: 22, height: 22)
                        .background(Brand.accent, in: Circle())
                        .overlay {
                            Circle()
                                .stroke(Brand.background, lineWidth: 2)
                        }
                }
            }

            Text(name.split(separator: " ").first.map(String.init) ?? name)
                .font(.caption2)
                .foregroundStyle(Brand.subtle)
                .lineLimit(1)
                .frame(width: 70)
        }
    }
}
