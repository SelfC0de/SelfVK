import SwiftUI

struct ComposeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Brand.background
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    TextEditor(text: $text)
                        .font(.body)
                        .foregroundStyle(Brand.foreground)
                        .scrollContentBackground(.hidden)
                        .padding(12)
                        .frame(maxWidth: .infinity, minHeight: 220)
                        .background(
                            Brand.panel,
                            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Brand.border, lineWidth: 1)
                        }
                        .overlay(alignment: .topLeading) {
                            if text.isEmpty {
                                Text("Что у вас нового?")
                                    .foregroundStyle(Brand.subtle)
                                    .padding(.horizontal, 17)
                                    .padding(.vertical, 21)
                                    .allowsHitTesting(false)
                            }
                        }

                    HStack(spacing: 12) {
                        composerAction("photo", title: "Фото")
                        composerAction("video", title: "Видео")
                        composerAction("paperclip", title: "Файл")
                        Spacer()
                    }

                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle("Новая публикация")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Brand.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundStyle(Brand.foreground)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Опубликовать") {
                        // Отправка будет подключена после проверки доступного метода API.
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Brand.accent)
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func composerAction(
        _ systemImage: String,
        title: String
    ) -> some View {
        Button(action: {}) {
            VStack(spacing: 5) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))

                Text(title)
                    .font(.caption2)
            }
            .foregroundStyle(Brand.subtle)
            .frame(width: 54, height: 52)
            .background(
                Brand.panel,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Brand.border, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}
