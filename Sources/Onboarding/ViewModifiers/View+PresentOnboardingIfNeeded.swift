//
//  View+PresentOnboardingIfNeeded.swift
//
//  Created by James Sedlacek on 6/28/24.
//

import SwiftUI

/// Extension providing onboarding sheet functionality to any SwiftUI View.
///
/// This extension adds a convenient modifier that presents the onboarding experience modally
/// in a sheet when needed, instead of conditionally swapping the root content.
public extension View {
    /// Presents onboarding content as a sheet if the user hasn't completed it yet.
    ///
    /// - Parameters:
    ///   - storage: The AppStorage property for tracking completion state (defaults to `.onboarding`)
    ///   - welcomeScreen: The welcome screen to present
    ///   - continueAction: Optional custom action to perform when continuing (defaults to marking complete)
    ///
    /// - Returns: A view that presents onboarding in a sheet when needed
    func presentOnboardingIfNeeded(
        storage: AppStorage<Bool> = .onboarding,
        welcomeScreen: WelcomeScreen,
        continueAction: (() -> Void)? = nil
    ) -> some View {
        modifier(
            OnboardingSheetModifier<EmptyView>(
                storage: storage,
                welcomeScreen: welcomeScreen,
                continueAction: continueAction,
                flowContent: nil
            )
        )
    }

    /// Presents onboarding as a sheet and allows for a custom onboarding flow after the welcome screen.
    ///
    /// - Parameters:
    ///   - flowContent: A view builder for additional steps after the welcome screen.
    func presentOnboardingIfNeeded<F: View>(
        storage: AppStorage<Bool> = .onboarding,
        welcomeScreen: WelcomeScreen,
        continueAction: (() -> Void)? = nil,
        @ViewBuilder flowContent: @escaping () -> F
    ) -> some View {
        modifier(
            OnboardingSheetModifier<F>(
                storage: storage,
                welcomeScreen: welcomeScreen,
                continueAction: continueAction,
                flowContent: flowContent
            )
        )
    }
}

@MainActor
private struct OnboardingSheetModifier<F: View> {
    private let welcomeScreen: WelcomeScreen
    private let continueAction: (() -> Void)?
    private let flowContent: (() -> F)?
    @AppStorage private var isOnboardingCompleted: Bool
    @State private var isWelcomeScreenCompleted: Bool = false

    init(
        storage: AppStorage<Bool>,
        welcomeScreen: WelcomeScreen,
        continueAction: (() -> Void)?,
        flowContent: (() -> F)? = nil
    ) {
        self._isOnboardingCompleted = storage
        self.welcomeScreen = welcomeScreen
        self.continueAction = continueAction
        self.flowContent = flowContent
    }

    private func handleContinue() {
        if let action = continueAction {
            action()
            isWelcomeScreenCompleted = true
            return
        }

        if flowContent != nil {
            isWelcomeScreenCompleted = true
        } else {
            isOnboardingCompleted = true
        }
    }

    private func onSheetDismiss() {
        isOnboardingCompleted = true
    }
}

extension OnboardingSheetModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .sheet(
                isPresented: $isOnboardingCompleted.inverse,
                onDismiss: onSheetDismiss,
                content: sheetContent
            )
    }

    @ViewBuilder
    private func sheetContent() -> some View {
        if let flowContent, isWelcomeScreenCompleted {
            flowContent()
        } else {
            welcomeScreenView()
                .interactiveDismissDisabled(true)
        }
    }
}

@MainActor
private extension OnboardingSheetModifier {
    @ViewBuilder
    func welcomeScreenView() -> some View {
        let screen = welcomeScreen.with(continueAction: handleContinue)
        switch screen {
        case let .apple(configuration):
            AppleWelcomeScreen(config: configuration)
        }
    }
}

#Preview("Welcome Screen Only") {
    VStack {
        Spacer()
    }
    .presentOnboardingIfNeeded(
        welcomeScreen: .mock
    )
}

#Preview("Welcome Screen with Flow") {
    VStack {
        Spacer()
    }
    .presentOnboardingIfNeeded(
        welcomeScreen: .mock,
        flowContent: {
            Text("Flow Content")
        }
    )
}
