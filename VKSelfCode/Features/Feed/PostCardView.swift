import Foundation
import SwiftUI

struct PostCardView: View {
    let item: FeedPost

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            authorHeader

            if !item.post.text.isEmpty {
                Text(item.post.text)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Brand.foreground)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)
                    .lineLimit(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let media = item.media.first {
                mediaPreview(media)
            }

            metrics
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Brand.panel.opacity(0.96),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Brand.border, lineWidth: 1)
        }
    }

    private var authorHeader: some View {
        HStack(spacing: 11) {
            AvatarView(
                url: item.author.avatarURL,
                name: item.author.name,
                size: 44
            )

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 5) {
                    Text(item.author.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Brand.foreground)
                        .lineLimit(1)

                    if item.author.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundStyle(Brand.accent)
                    }
                }

                Text("\(item.author.handle) · \(relativeDate(item.post.publishedAt))")
                    .font(.caption)
                    .foregroundStyle(Brand.subtle)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Image(systemName: "ellipsis")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Brand.subtle)
                .frame(width: 30, height: 30)
        }
    }

    private func mediaPreview(_ media: VKAttachment) -> some View {
        ZStack {
            AsyncImage(url: media.previewURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    Rectangle()
                        .fill(Brand.elevated)
                        .overlay {
                            ProgressView()
                                .tint(Brand.accent)
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1.42, contentMode: .fit)
            .clipShape(
                RoundedRectangle(cornerRadius: 17, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .stroke(Brand.border, lineWidth: 1)
            }

            if media.isVideo {
                Image(systemName: "play.fill")
                    .font(.title2)
                    .foregroundStyle(.black)
                    .frame(width: 54, height: 54)
                    .background(Brand.accent, in: Circle())
                    .shadow(radius: 12)
            }

            if item.media.count > 1 {
                Text("1/\(item.media.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Brand.foreground)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.66), in: Capsule())
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .topTrailing
                    )
                    .padding(10)
            }
        }
    }

    private var metrics: some View {
        HStack(spacing: 23) {
            metric(
                systemImage: item.post.likes?.userLikes == 1 ? "heart.fill" : "heart",
                value: item.post.likes?.count ?? 0,
                highlighted: item.post.likes?.userLikes == 1
            )

            metric(
                systemImage: "bubble.left",
                value: item.post.comments?.count ?? 0
            )

            metric(
                systemImage: "arrowshape.turn.up.right",
                value: item.post.reposts?.count ?? 0
            )

            Spacer(minLength: 8)

            Image(systemName: "bookmark")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Brand.subtle)
                .frame(width: 30, height: 30)
        }
    }

    private func metric(
        systemImage: String,
        value: Int,
        highlighted: Bool = false
    ) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .medium))

            Text(value.formatted())
                .font(.system(size: 13, weight: .medium))
        }
        .foregroundStyle(highlighted ? Brand.danger : Brand.subtle)
    }

    private func relativeDate(_ date: Date) -> String {
        RelativeDateTimeFormatter.shared.localizedString(
            for: date,
            relativeTo: Date()
        )
    }
}

private extension RelativeDateTimeFormatter {
    static let shared: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
}
