import SwiftUI

struct InboxView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Brand.background
                    .ignoresSafeArea()

                VStack(spacing: 18) {
                    Image(systemName: "envelope.open")
                        .font(.system(size: 42, weight: .light))
                        .foregroundStyle(Brand.accent)

                    Text("Входящие")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Brand.foreground)

                    Text("Диалоги появятся здесь после подключения доступного API сообщений.")
                        .font(.subheadline)
                        .foregroundStyle(Brand.subtle)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 300)
                }
                .padding(24)
            }
            .navigationTitle("Входящие")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Brand.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}
