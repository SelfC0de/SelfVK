import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var auth: VKIDService
    @EnvironmentObject private var model: AppModel
    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            FeedView()
                .tabItem { Label("Главная", systemImage: "house.fill") }
                .tag(0)

            MediaGridView()
                .tabItem { Label("Медиа", systemImage: "rectangle.stack.fill") }
                .tag(1)

            ProfileView()
                .tabItem { Label("Профиль", systemImage: "person.crop.circle.fill") }
                .tag(2)

            SettingsView()
                .tabItem { Label("Настройки", systemImage: "gearshape.fill") }
                .tag(3)
        }
        .toolbarBackground(Brand.background.opacity(0.97), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .task(id: auth.session?.userId.value) {
            await model.refresh(using: auth)
        }
    }
}
