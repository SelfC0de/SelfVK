import Foundation
import SwiftUI

struct PostCardView: View {
    let item: FeedPost

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            authorHeader

            if !item.post.text.isEmpty {
                Text(item.post.text)
                    .font(.subheadline)
                    .foregroundStyle(Brand.foreground)
                    .multilineTextAlignment(.leading)
                    .lineLimit(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let media = item.media.first {
                mediaPreview(media)
            }

            metrics
        }
        .padding(14)
        .background(Brand.panel, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Brand.border, lineWidth: 1)
        }
    }

    private var authorHeader: some View {
        HStack(spacing: 11) {
            AvatarView(url: item.author.avatarURL, name: item.author.name, size: 42)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 5) {
                    Text(item.author.name)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Brand.foreground)
                    if item.author.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundStyle(Brand.accent)
                    }
                }
                Text("\(item.author.handle) · \(relativeDate(item.post.publishedAt))")
                    .font(.caption)
                    .foregroundStyle(Brand.subtle)
            }

            Spacer()
            Image(systemName: "ellipsis")
                .foregroundStyle(Brand.subtle)
        }
    }

    private func mediaPreview(_ media: VKAttachment) -> some View {
        ZStack {
            AsyncImage(url: media.previewURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Rectangle()
                        .fill(Brand.elevated)
                        .overlay { ProgressView().tint(Brand.accent) }
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1.45, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

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
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(10)
            }
        }
    }

    private var metrics: some View {
        HStack(spacing: 20) {
            MetricLabel(systemImage: "heart", value: item.post.likes?.count ?? 0)
            MetricLabel(systemImage: "bubble.left", value: item.post.comments?.count ?? 0)
            MetricLabel(systemImage: "arrow.2.squarepath", value: item.post.reposts?.count ?? 0)
            Spacer()
            if let views = item.post.views?.count {
                MetricLabel(systemImage: "eye", value: views)
            }
            Image(systemName: "bookmark")
                .font(.caption)
                .foregroundStyle(Brand.subtle)
        }
    }

    private func relativeDate(_ date: Date) -> String {
        RelativeDateTimeFormatter.shared.localizedString(for: date, relativeTo: Date())
    }
}

private extension RelativeDateTimeFormatter {
    static let shared: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
}
