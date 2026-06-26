import Foundation
import SwiftUI
import WebKit

struct MediaGridView: View {
    @EnvironmentObject private var model: AppModel
    @State private var selected: MediaItem?
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)

    var body: some View {
        NavigationStack {
            ScrollView {
                if model.mediaItems.isEmpty {
                    ContentUnavailableView(
                        "Медиа пока нет",
                        systemImage: "photo.on.rectangle.angled",
                        description: Text("Фотографии и видео из ленты появятся здесь.")
                    )
                    .foregroundStyle(Brand.subtle)
                    .padding(.top, 100)
                } else {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(model.mediaItems) { item in
                            Button {
                                selected = item
                            } label: {
                                ZStack {
                                    AsyncImage(url: item.previewURL) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image.resizable().scaledToFill()
                                        default:
                                            Brand.elevated
                                        }
                                    }
                                    .frame(height: 128)
                                    .clipped()

                                    if item.isVideo {
                                        Image(systemName: "play.fill")
                                            .foregroundStyle(.white)
                                            .padding(10)
                                            .background(.black.opacity(0.55), in: Circle())
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .background(Brand.background)
            .navigationTitle("Медиа")
            .toolbarBackground(Brand.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(item: $selected) { item in
                MediaItemViewer(item: item)
            }
        }
    }
}

private struct MediaItemViewer: View {
    let item: MediaItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                if item.isVideo, let videoURL = item.videoURL {
                    EmbeddedVideoWrapper(url: videoURL)
                } else {
                    AsyncImage(url: item.previewURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFit()
                        default:
                            ProgressView().tint(Brand.accent)
                        }
                    }
                }
            }
            .navigationTitle(item.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct EmbeddedVideoWrapper: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let view = WKWebView(frame: .zero, configuration: config)
        view.load(URLRequest(url: url))
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
