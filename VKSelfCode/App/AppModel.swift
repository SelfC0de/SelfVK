import Combine
import Foundation

@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var profile: VKUser = .sample
    @Published private(set) var feed: [FeedPost] = FeedPost.samples
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published var isDemoMode = false

    private let api = VKAPIClient()

    var mediaItems: [MediaItem] {
        feed.flatMap { item in
            item.media.compactMap { attachment in
                guard let previewURL = attachment.previewURL else { return nil }
                return MediaItem(
                    id: "\(item.id)_\(attachment.id)",
                    previewURL: previewURL,
                    videoURL: attachment.videoURL,
                    isVideo: attachment.isVideo,
                    title: attachment.video?.title ?? item.author.name
                )
            }
        }
    }

    func enterDemoMode() {
        isDemoMode = true
        profile = .sample
        feed = FeedPost.samples
        errorMessage = nil
    }

    func leaveDemoMode() {
        isDemoMode = false
        profile = .sample
        feed = FeedPost.samples
        errorMessage = nil
    }

    func refresh(using auth: VKIDService) async {
        guard !isDemoMode else { return }
        guard let token = auth.accessToken else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            async let profileRequest = api.fetchCurrentUser(token: token)
            async let feedRequest = api.fetchFeed(token: token)
            let (profile, response) = try await (profileRequest, feedRequest)
            self.profile = profile
            self.feed = makeFeed(from: response)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func makeFeed(from response: VKNewsfeedResponse) -> [FeedPost] {
        let profiles = Dictionary(uniqueKeysWithValues: response.profiles.map { ($0.id, $0) })
        let groups = Dictionary(uniqueKeysWithValues: response.groups.map { ($0.id, $0) })

        return response.items.map { post in
            if post.sourceId < 0, let group = groups[abs(post.sourceId)] {
                return FeedPost(
                    post: post,
                    author: FeedAuthor(
                        id: -group.id,
                        name: group.name,
                        handle: group.screenName.map { "@\($0)" } ?? "Сообщество",
                        avatarURL: group.avatarURL,
                        isVerified: group.verified == 1,
                        isGroup: true
                    )
                )
            }

            let user = profiles[post.sourceId] ?? profile
            return FeedPost(
                post: post,
                author: FeedAuthor(
                    id: user.id,
                    name: user.fullName,
                    handle: user.domain.map { "@\($0)" } ?? "id\(user.id)",
                    avatarURL: user.avatarURL,
                    isVerified: user.verified == 1,
                    isGroup: false
                )
            )
        }
    }
}
