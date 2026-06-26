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
        ZStack {
            Brand.background
                .ignoresSafeArea()

            Group {
                if auth.session != nil || model.isDemoMode {
                    MainTabView()
                } else {
                    AuthView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.25), value: auth.session != nil)
        .animation(.easeInOut(duration: 0.25), value: model.isDemoMode)
    }
}
