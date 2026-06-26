import Foundation
import SwiftUI
import WebKit

struct PostDetailView: View {
    let item: FeedPost
    @State private var selectedMediaIndex = 0
    @State private var fullScreenPhoto: PhotoSelection?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                authorHeader

                if !item.post.text.isEmpty {
                    Text(item.post.text)
                        .font(.body)
                        .foregroundStyle(Brand.foreground)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if !item.media.isEmpty {
                    mediaPager
                }

                engagement
                commentsPreview
            }
            .padding(16)
        }
        .background(Brand.background.ignoresSafeArea())
        .navigationTitle("Публикация")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Brand.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .fullScreenCover(item: $fullScreenPhoto) { selection in
            ZoomablePhotoView(url: selection.url)
        }
    }

    private var authorHeader: some View {
        HStack(spacing: 12) {
            AvatarView(url: item.author.avatarURL, name: item.author.name, size: 46)
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 5) {
                    Text(item.author.name)
                        .font(.headline)
                        .foregroundStyle(Brand.foreground)
                    if item.author.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(Brand.accent)
                    }
                }
                Text(item.author.handle)
                    .font(.caption)
                    .foregroundStyle(Brand.subtle)
            }
            Spacer()
            Button("Подписаться") {}
                .font(.caption.weight(.bold))
                .foregroundStyle(Brand.accent)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .overlay { Capsule().stroke(Brand.accent, lineWidth: 1) }
        }
    }

    private var mediaPager: some View {
        TabView(selection: $selectedMediaIndex) {
            ForEach(Array(item.media.enumerated()), id: \.offset) { index, media in
                mediaContent(media)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: item.media.count > 1 ? .automatic : .never))
        .frame(height: 420)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Brand.border, lineWidth: 1)
        }
    }

    @ViewBuilder
    private func mediaContent(_ media: VKAttachment) -> some View {
        if media.isVideo, let videoURL = media.videoURL {
            EmbeddedWebVideo(url: videoURL)
                .background(Brand.elevated)
        } else {
            Button {
                fullScreenPhoto = media.previewURL.map(PhotoSelection.init)
            } label: {
                AsyncImage(url: media.previewURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    default:
                        ZStack {
                            Brand.elevated
                            ProgressView().tint(Brand.accent)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
            }
            .buttonStyle(.plain)
        }
    }

    private var engagement: some View {
        VStack(spacing: 12) {
            HStack {
                Text("\((item.post.likes?.count ?? 0).formatted()) отметок")
                Spacer()
                Text("\((item.post.comments?.count ?? 0).formatted()) комментариев")
                Text("·")
                Text("\((item.post.reposts?.count ?? 0).formatted()) репостов")
            }
            .font(.caption)
            .foregroundStyle(Brand.subtle)

            Divider().overlay(Brand.border)

            HStack {
                actionButton("heart", "Нравится")
                Spacer()
                actionButton("bubble.left", "Ответить")
                Spacer()
                actionButton("arrow.2.squarepath", "Репост")
                Spacer()
                Image(systemName: "bookmark")
                    .foregroundStyle(Brand.subtle)
            }
        }
        .padding(14)
        .background(Brand.panel, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
    }

    private func actionButton(_ icon: String, _ title: String) -> some View {
        Button(action: {}) {
            Label(title, systemImage: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Brand.subtle)
        }
    }

    private var commentsPreview: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Комментарии")
                .font(.headline)
                .foregroundStyle(Brand.foreground)

            comment(
                name: "Maria Dev",
                text: "Выглядит чисто. Особенно удачно получился просмотр медиа.",
                initials: "MD"
            )
            comment(
                name: "DebugDan",
                text: "Жду первую сборку из GitHub Actions.",
                initials: "DD"
            )

            HStack(spacing: 10) {
                AvatarView(url: nil, name: "Self Code", size: 34)
                Text("Написать комментарий…")
                    .font(.subheadline)
                    .foregroundStyle(Brand.subtle)
                Spacer()
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(Brand.accent)
            }
            .padding(12)
            .background(Brand.elevated, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
    }

    private func comment(name: String, text: String, initials: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            AvatarView(url: nil, name: initials, size: 34)
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Brand.foreground)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(Brand.subtle)
            }
            Spacer()
        }
    }
}

private struct EmbeddedWebVideo: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard uiView.url != url else { return }
        uiView.load(URLRequest(url: url))
    }
}

private struct ZoomablePhotoView: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .gesture(
                            MagnifyGesture()
                                .onChanged { value in
                                    scale = max(1, min(lastScale * value.magnification, 5))
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                }
                        )
                default:
                    ProgressView().tint(Brand.accent)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.headline.bold())
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(.black.opacity(0.6), in: Circle())
            }
            .padding()
        }
    }
}

private struct PhotoSelection: Identifiable {
    let url: URL
    var id: String { url.absoluteString }
}
