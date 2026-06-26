import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var auth: VKIDService
    @EnvironmentObject private var model: AppModel

    @State private var selection: AppSection = .home
    @State private var isComposerPresented = false

    var body: some View {
        ZStack {
            Brand.background
                .ignoresSafeArea()

            selectedContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            SelfCodeTabBar(
                selection: $selection,
                composeAction: {
                    isComposerPresented = true
                }
            )
        }
        .sheet(isPresented: $isComposerPresented) {
            ComposeView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .preferredColorScheme(.dark)
        }
        .task(id: auth.session?.userId.value) {
            await model.refresh(using: auth)
        }
    }

    @ViewBuilder
    private var selectedContent: some View {
        switch selection {
        case .home:
            FeedView()
        case .explore:
            MediaGridView()
        case .inbox:
            InboxView()
        case .profile:
            ProfileView()
        }
    }
}

private enum AppSection: Hashable {
    case home
    case explore
    case inbox
    case profile
}

private struct SelfCodeTabBar: View {
    @Binding var selection: AppSection
    let composeAction: () -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            tabButton(
                section: .home,
                title: "Главная",
                icon: "house.fill"
            )

            tabButton(
                section: .explore,
                title: "Обзор",
                icon: "magnifyingglass"
            )

            composeButton
                .frame(maxWidth: .infinity)

            tabButton(
                section: .inbox,
                title: "Входящие",
                icon: "envelope"
            )

            tabButton(
                section: .profile,
                title: "Профиль",
                icon: "person"
            )
        }
        .frame(height: 72)
        .padding(.horizontal, 8)
        .padding(.top, 7)
        .background {
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)

                Brand.background
                    .opacity(0.78)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Brand.border)
                .frame(height: 1)
        }
    }

    private func tabButton(
        section: AppSection,
        title: String,
        icon: String
    ) -> some View {
        let isSelected = selection == section

        return Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                selection = section
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 21, weight: .semibold))
                    .symbolVariant(isSelected ? .fill : .none)

                Text(title)
                    .font(.system(size: 10.5, weight: isSelected ? .semibold : .regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .foregroundStyle(isSelected ? Brand.accent : Brand.subtle)
            .frame(maxWidth: .infinity)
            .frame(height: 57)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var composeButton: some View {
        Button(action: composeAction) {
            Image(systemName: "plus")
                .font(.system(size: 25, weight: .medium))
                .foregroundStyle(.black)
                .frame(width: 58, height: 58)
                .background(
                    Brand.accent,
                    in: Circle()
                )
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.17), lineWidth: 1)
                }
                .shadow(color: Brand.accent.opacity(0.28), radius: 14, y: 5)
        }
        .buttonStyle(.plain)
        .offset(y: -8)
        .accessibilityLabel("Создать публикацию")
    }
}
