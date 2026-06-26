import Combine
import Foundation
import UIKit
import VKID

@MainActor
final class VKIDService: NSObject, ObservableObject {
    enum State: Equatable {
        case needsConfiguration
        case ready
        case authorizing
        case authorized
        case failed(String)
    }

    @Published private(set) var state: State = .needsConfiguration
    @Published private(set) var session: UserSession?

    var accessToken: String? {
        session?.accessToken.value
    }

    var isConfigured: Bool {
        AppConfiguration.isVKIDConfigured
    }

    override init() {
        super.init()
        configure()
    }

    func configure() {
        guard AppConfiguration.isVKIDConfigured else {
            state = .needsConfiguration
            return
        }

        do {
            let config = Configuration(
                appCredentials: AppCredentials(
                    clientId: AppConfiguration.clientID,
                    clientSecret: AppConfiguration.clientSecret
                ),
                appearance: Appearance(colorScheme: .dark, locale: .ru),
                loggingEnabled: true
            )
            try VKID.shared.set(config: config)
            VKID.shared.add(observer: self)
            session = VKID.shared.currentAuthorizedSession
            state = session == nil ? .ready : .authorized
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func authorize() {
        guard isConfigured else {
            state = .needsConfiguration
            return
        }
        guard let presenter = UIApplication.shared.topViewController else {
            state = .failed("Не удалось открыть экран авторизации")
            return
        }

        state = .authorizing
        let configuration = AuthConfiguration(
            scope: Scope(AppConfiguration.authScope),
            forceWebViewFlow: false,
            prompt: .login
        )

        VKID.shared.authorize(
            with: configuration,
            using: .uiViewController(presenter)
        ) { [weak self] result in
            guard let self else { return }
            do {
                let session = try result.get()
                self.session = session
                self.state = .authorized
            } catch {
                self.state = .failed(error.localizedDescription)
            }
        }
    }

    func logout() {
        guard let session else {
            state = isConfigured ? .ready : .needsConfiguration
            return
        }

        session.logout { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.session = nil
                self.state = self.isConfigured ? .ready : .needsConfiguration
            case .failure(let error):
                self.state = .failed(error.localizedDescription)
            }
        }
    }
}

extension VKIDService: VKIDObserver {
    func vkid(_ vkid: VKID, didStartAuthUsing oAuth: OAuthProvider) {
        state = .authorizing
    }

    func vkid(_ vkid: VKID, didCompleteAuthWith result: AuthResult, in oAuth: OAuthProvider) {
        if case .success(let session) = result {
            self.session = session
            state = .authorized
        }
    }

    func vkid(_ vkid: VKID, didLogoutFrom session: UserSession, with result: LogoutResult) {
        if case .success = result {
            self.session = nil
            state = isConfigured ? .ready : .needsConfiguration
        }
    }
}

private extension UIApplication {
    var topViewController: UIViewController? {
        let root = connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController
        return root?.topmostPresentedViewController
    }
}

private extension UIViewController {
    var topmostPresentedViewController: UIViewController {
        if let presentedViewController {
            return presentedViewController.topmostPresentedViewController
        }
        if let navigationController = self as? UINavigationController,
           let visible = navigationController.visibleViewController {
            return visible.topmostPresentedViewController
        }
        if let tabBarController = self as? UITabBarController,
           let selected = tabBarController.selectedViewController {
            return selected.topmostPresentedViewController
        }
        return self
    }
}
