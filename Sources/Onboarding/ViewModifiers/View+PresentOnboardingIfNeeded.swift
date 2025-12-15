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
    ///   - config: Configuration for customizing the onboarding experience
    ///   - continueAction: Optional custom action to perform when continuing (defaults to marking complete)
    ///
    /// - Returns: A view that presents onboarding in a sheet when needed
    func presentOnboardingIfNeeded(
        storage: AppStorage<Bool> = .onboarding,
        config: OnboardingConfiguration,
        continueAction: (() -> Void)? = nil
    ) -> some View {
        modifier(
            OnboardingSheetModifier<EmptyView>(
                storage: storage,
                config: config,
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
        config: OnboardingConfiguration,
        continueAction: (() -> Void)? = nil,
        @ViewBuilder flowContent: @escaping () -> F
    ) -> some View {
        modifier(
            OnboardingSheetModifier<F>(
                storage: storage,
                config: config,
                continueAction: continueAction,
                flowContent: flowContent
            )
        )
    }
}

@MainActor
private struct OnboardingSheetModifier<F: View> {
    private let config: OnboardingConfiguration
    private let continueAction: (() -> Void)?
    private let flowContent: (() -> F)?
    @AppStorage private var isOnboardingCompleted: Bool
    @State private var isWelcomeScreenCompleted: Bool = false

    init(
        storage: AppStorage<Bool>,
        config: OnboardingConfiguration,
        continueAction: (() -> Void)?,
        flowContent: (() -> F)? = nil
    ) {
        self._isOnboardingCompleted = storage
        self.config = config
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
            welcomeScreen()
                .interactiveDismissDisabled(true)
        }
    }
}

@MainActor
private extension OnboardingSheetModifier {
    @ViewBuilder
    func welcomeScreen() -> some View {
        switch config.welcomeScreen {
        case let .apple(configuration):
            AppleWelcomeScreen(
                config: configuration.with(continueAction: handleContinue)
            )
        }
    }
}

#Preview("Welcome Screen Only") {
    VStack {
        Spacer()
    }
    .presentOnboardingIfNeeded(config: .mock)
}

#Preview("Welcome Screen with Flow") {
    VStack {
        Spacer()
    }
    .presentOnboardingIfNeeded(
        config: .mock,
        flowContent: {
            Text("Flow Content")
        }
    )
}
