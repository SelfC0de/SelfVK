import SwiftUI

@main
struct VKSelfCodeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var auth = VKIDService()
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
                .environmentObject(model)
                .preferredColorScheme(.dark)
                .tint(Brand.accent)
        }
    }
}

private struct RootView: View {
    @EnvironmentObject private var auth: VKIDService
    @EnvironmentObject private var model: AppModel

    var body: some View {
        Group {
            if auth.session != nil || model.isDemoMode {
                MainTabView()
            } else {
                AuthView()
            }
        }
        .background(Brand.background.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.25), value: auth.session != nil)
        .animation(.easeInOut(duration: 0.25), value: model.isDemoMode)
    }
}
