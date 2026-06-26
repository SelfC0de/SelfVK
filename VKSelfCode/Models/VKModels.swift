import Foundation

struct VKCity: Decodable, Hashable {
    let id: Int?
    let title: String?
}

struct VKCounters: Decodable, Hashable {
    let followers: Int?
    let friends: Int?
    let photos: Int?
    let videos: Int?
    let posts: Int?
}

struct VKUser: Decodable, Hashable, Identifiable {
    let id: Int
    let firstName: String
    let lastName: String
    let photo100: String?
    let photo200: String?
    let photo400: String?
    let domain: String?
    let status: String?
    let online: Int?
    let verified: Int?
    let city: VKCity?
    let counters: VKCounters?

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case photo100 = "photo_100"
        case photo200 = "photo_200"
        case photo400 = "photo_400_orig"
        case domain
        case status
        case online
        case verified
        case city
        case counters
    }

    var fullName: String {
        [firstName, lastName].filter { !$0.isEmpty }.joined(separator: " ")
    }

    var avatarURL: URL? {
        URL(string: photo400 ?? photo200 ?? photo100 ?? "")
    }

    static let sample = VKUser(
        id: 1,
        firstName: "Self",
        lastName: "Code",
        photo100: nil,
        photo200: nil,
        photo400: nil,
        domain: "selfcode.dev",
        status: "Разработка независимого клиента VK",
        online: 1,
        verified: 0,
        city: VKCity(id: 1, title: "Helsinki"),
        counters: VKCounters(followers: 1240, friends: 318, photos: 146, videos: 28, posts: 267)
    )
}

struct VKGroup: Decodable, Hashable, Identifiable {
    let id: Int
    let name: String
    let screenName: String?
    let photo100: String?
    let photo200: String?
    let verified: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case screenName = "screen_name"
        case photo100 = "photo_100"
        case photo200 = "photo_200"
        case verified
    }

    var avatarURL: URL? {
        URL(string: photo200 ?? photo100 ?? "")
    }
}

struct VKCount: Decodable, Hashable {
    let count: Int?
    let userLikes: Int?

    enum CodingKeys: String, CodingKey {
        case count
        case userLikes = "user_likes"
    }
}

struct VKViews: Decodable, Hashable {
    let count: Int?
}

struct VKPhotoSize: Decodable, Hashable {
    let url: String
    let width: Int?
    let height: Int?

    var area: Int {
        (width ?? 0) * (height ?? 0)
    }
}

struct VKPhoto: Decodable, Hashable, Identifiable {
    let id: Int
    let ownerId: Int?
    let text: String?
    let sizes: [VKPhotoSize]

    enum CodingKeys: String, CodingKey {
        case id
        case ownerId = "owner_id"
        case text
        case sizes
    }

    var bestURL: URL? {
        sizes.max(by: { $0.area < $1.area }).flatMap { URL(string: $0.url) }
    }
}

struct VKVideoImage: Decodable, Hashable {
    let url: String
    let width: Int?
    let height: Int?

    var area: Int {
        (width ?? 0) * (height ?? 0)
    }
}

struct VKVideo: Decodable, Hashable, Identifiable {
    let id: Int
    let ownerId: Int?
    let title: String?
    let description: String?
    let duration: Int?
    let image: [VKVideoImage]?
    let firstFrame: [VKVideoImage]?
    let player: String?

    enum CodingKeys: String, CodingKey {
        case id
        case ownerId = "owner_id"
        case title
        case description
        case duration
        case image
        case firstFrame = "first_frame"
        case player
    }

    var previewURL: URL? {
        let images = (image ?? []) + (firstFrame ?? [])
        return images.max(by: { $0.area < $1.area }).flatMap { URL(string: $0.url) }
    }

    var playerURL: URL? {
        URL(string: player ?? "")
    }
}

struct VKLink: Decodable, Hashable {
    let url: String?
    let title: String?
    let description: String?
    let photo: VKPhoto?
}

struct VKAttachment: Decodable, Hashable, Identifiable {
    let type: String
    let photo: VKPhoto?
    let video: VKVideo?
    let link: VKLink?

    var id: String {
        switch type {
        case "photo":
            return "photo_\(photo?.id ?? 0)"
        case "video":
            return "video_\(video?.id ?? 0)"
        default:
            return "\(type)_\(link?.url ?? String(photo?.id ?? video?.id ?? 0))"
        }
    }

    var previewURL: URL? {
        photo?.bestURL ?? video?.previewURL ?? link?.photo?.bestURL
    }

    var videoURL: URL? {
        video?.playerURL
    }

    var isVideo: Bool {
        type == "video"
    }
}

struct VKPost: Decodable, Hashable, Identifiable {
    let sourceId: Int
    let postId: Int
    let date: TimeInterval
    let text: String
    let attachments: [VKAttachment]?
    let comments: VKCount?
    let likes: VKCount?
    let reposts: VKCount?
    let views: VKViews?

    enum CodingKeys: String, CodingKey {
        case sourceId = "source_id"
        case postId = "post_id"
        case date
        case text
        case attachments
        case comments
        case likes
        case reposts
        case views
    }

    var id: String {
        "\(sourceId)_\(postId)"
    }

    var publishedAt: Date {
        Date(timeIntervalSince1970: date)
    }
}

struct VKNewsfeedResponse: Decodable {
    let items: [VKPost]
    let profiles: [VKUser]
    let groups: [VKGroup]
    let nextFrom: String?

    enum CodingKeys: String, CodingKey {
        case items
        case profiles
        case groups
        case nextFrom = "next_from"
    }
}

struct FeedAuthor: Hashable {
    let id: Int
    let name: String
    let handle: String
    let avatarURL: URL?
    let isVerified: Bool
    let isGroup: Bool
}

struct FeedPost: Identifiable, Hashable {
    let post: VKPost
    let author: FeedAuthor

    var id: String { post.id }

    var media: [VKAttachment] {
        post.attachments?.filter { $0.previewURL != nil } ?? []
    }
}

struct MediaItem: Identifiable, Hashable {
    let id: String
    let previewURL: URL
    let videoURL: URL?
    let isVideo: Bool
    let title: String
}

extension FeedPost {
    static let samples: [FeedPost] = {
        let author = FeedAuthor(
            id: 1,
            name: "SelfCode",
            handle: "@selfcode.dev",
            avatarURL: nil,
            isVerified: true,
            isGroup: false
        )
        let photos = [
            "https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=1400&q=85",
            "https://images.unsplash.com/photo-1550745165-9bc0b252726f?auto=format&fit=crop&w=1400&q=85",
            "https://images.unsplash.com/photo-1497366811353-6870744d04b2?auto=format&fit=crop&w=1400&q=85"
        ]

        return photos.enumerated().map { index, url in
            let photo = VKPhoto(
                id: index + 1,
                ownerId: 1,
                text: nil,
                sizes: [VKPhotoSize(url: url, width: 1400, height: 900)]
            )
            let post = VKPost(
                sourceId: 1,
                postId: index + 1,
                date: Date().addingTimeInterval(TimeInterval(-index * 7200)).timeIntervalSince1970,
                text: [
                    "Собираю первый интерфейс VK [SelfCode]. Темная тема, быстрый доступ к ленте и минимум визуального шума.",
                    "Новый экран медиа: фотографии и видео открываются без лишних переходов.",
                    "GitHub Actions полностью генерирует Xcode-проект и собирает unsigned IPA."
                ][index],
                attachments: [VKAttachment(type: "photo", photo: photo, video: nil, link: nil)],
                comments: VKCount(count: 12 + index * 7, userLikes: nil),
                likes: VKCount(count: 96 + index * 31, userLikes: 0),
                reposts: VKCount(count: 8 + index * 3, userLikes: nil),
                views: VKViews(count: 1400 + index * 800)
            )
            return FeedPost(post: post, author: author)
        }
    }()
}
