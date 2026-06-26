import Foundation
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var auth: VKIDService
    @EnvironmentObject private var model: AppModel
    @AppStorage("settings.compactFeed") private var compactFeed = false
    @AppStorage("settings.autoplayVideo") private var autoplayVideo = false
    @AppStorage("settings.haptics") private var haptics = true

    var body: some View {
        NavigationStack {
            List {
                profileSection
                appearanceSection
                sessionSection
                aboutSection
                logoutSection
            }
            .scrollContentBackground(.hidden)
            .background(Brand.background)
            .listSectionSpacing(18)
            .navigationTitle("Настройки")
            .toolbarBackground(Brand.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private var profileSection: some View {
        Section {
            HStack(spacing: 12) {
                AvatarView(
                    url: model.profile.avatarURL,
                    name: model.profile.fullName,
                    size: 54,
                    showsOnline: auth.session != nil || model.isDemoMode
                )
                VStack(alignment: .leading, spacing: 4) {
                    Text(model.profile.fullName)
                        .font(.headline)
                        .foregroundStyle(Brand.foreground)
                    Text(model.profile.domain.map { "@\($0)" } ?? "VK [SelfCode]")
                        .font(.caption)
                        .foregroundStyle(Brand.subtle)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(Brand.subtle)
            }
            .padding(.vertical, 4)
        }
        .listRowBackground(Brand.panel)
    }

    private var appearanceSection: some View {
        Section("Интерфейс") {
            Toggle(isOn: $compactFeed) {
                Label("Компактная лента", systemImage: "rectangle.compress.vertical")
            }
            Toggle(isOn: $autoplayVideo) {
                Label("Автовоспроизведение видео", systemImage: "play.rectangle.fill")
            }
            Toggle(isOn: $haptics) {
                Label("Тактильный отклик", systemImage: "iphone.radiowaves.left.and.right")
            }
        }
        .tint(Brand.accent)
        .listRowBackground(Brand.panel)
        .foregroundStyle(Brand.foreground)
    }

    private var sessionSection: some View {
        Section("Сессия") {
            LabeledContent("Режим") {
                Text(model.isDemoMode ? "Демонстрация" : "VK ID")
                    .foregroundStyle(Brand.accent)
            }

            if let session = auth.session {
                LabeledContent("Пользователь") {
                    Text(String(session.userId.value))
                }
                LabeledContent("Создана") {
                    Text(session.creationDate, format: .dateTime.day().month().year())
                }
                LabeledContent("Токен") {
                    Text(session.accessToken.isExpired ? "Истёк" : "Активен")
                        .foregroundStyle(session.accessToken.isExpired ? Brand.danger : Brand.accent)
                }
            } else {
                Label("Реальная сессия не активна", systemImage: "key.slash")
                    .foregroundStyle(Brand.subtle)
            }

            Label("Токены хранит VK ID SDK в Keychain", systemImage: "lock.shield")
                .font(.caption)
                .foregroundStyle(Brand.subtle)
        }
        .listRowBackground(Brand.panel)
        .foregroundStyle(Brand.foreground)
    }

    private var aboutSection: some View {
        Section("О приложении") {
            LabeledContent("Название", value: "VK [SelfCode]")
            LabeledContent("Версия", value: version)
            LabeledContent("API", value: AppConfiguration.apiVersion)
            LabeledContent("Сборка", value: "GitHub Actions")
        }
        .listRowBackground(Brand.panel)
        .foregroundStyle(Brand.foreground)
    }

    private var logoutSection: some View {
        Section {
            Button(role: .destructive) {
                if model.isDemoMode {
                    model.leaveDemoMode()
                } else {
                    auth.logout()
                }
            } label: {
                Label("Выйти", systemImage: "rectangle.portrait.and.arrow.right")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundStyle(Brand.danger)
            }
        }
        .listRowBackground(Brand.panel)
    }

    private var version: String {
        let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(short) (\(build))"
    }
}
