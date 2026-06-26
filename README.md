# VK [SelfCode]

Независимый iOS-клиент VK с тёмным SwiftUI-интерфейсом. Проект рассчитан на разработку без локального Xcode: `.xcodeproj` генерируется через XcodeGen, а unsigned IPA собирается в GitHub Actions.

## Реализовано в первом каркасе

- авторизация через официальный VK ID SDK и OAuth 2.1;
- восстановление сессии из Keychain через VK ID SDK;
- API-клиент для `users.get` и `newsfeed.get`;
- профиль текущего пользователя;
- лента публикаций;
- карточка и детальный экран поста;
- просмотр фотографий с масштабированием;
- встроенный просмотр VK-видео через WebKit;
- медиагалерея;
- настройки приложения и выход из сессии;
- демонстрационный режим без VK ID credentials;
- автоматическая сборка unsigned IPA.

## GitHub Secrets

В `Settings → Secrets and variables → Actions` добавьте:

| Secret | Значение |
|---|---|
| `VK_CLIENT_ID` | ID приложения из кабинета VK ID |
| `VK_CLIENT_SECRET` | защищённый ключ приложения VK ID |

В кабинете VK ID для iOS-приложения укажите Bundle ID:

```text
dev.selfcode.vk
```

Callback URL scheme формируется автоматически:

```text
vk<VK_CLIENT_ID>
```

Без secrets приложение соберётся, но предложит только демонстрационный интерфейс.

## Сборка

1. Откройте вкладку `Actions`.
2. Выберите workflow `Build iOS`.
3. Нажмите `Run workflow`.
4. После успешной сборки скачайте artifact `VKSelfCode-unsigned-<commit>`.
5. В artifact находятся `VKSelfCode-unsigned.ipa` и SHA-256 checksum.

Unsigned IPA предназначен для последующей подписи через AltStore, SideStore, Sideloadly или другой используемый вами способ.

## Структура

```text
VKSelfCode/
├── App/           # lifecycle и состояние приложения
├── Core/          # VK ID, VK API, конфигурация и тема
├── Models/        # модели API и UI
├── Features/      # Auth, Feed, Post, Media, Profile, Settings
└── Resources/     # Info.plist и Assets.xcassets
```

`project.yml` является источником истины для Xcode-проекта. Сгенерированный `.xcodeproj` намеренно не хранится в репозитории.

## Локальная генерация на macOS

```bash
brew install xcodegen
xcodegen generate
open VKSelfCode.xcodeproj
```
