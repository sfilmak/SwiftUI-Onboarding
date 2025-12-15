//
//  View+ShowOnboardingIfNeeded.swift
//
//  Created by James Sedlacek on 12/30/23.
//

import SwiftUI

/// Extension providing onboarding functionality to any SwiftUI View.
///
/// This extension adds a convenient modifier that automatically handles the display
/// of onboarding content based on the user's completion status. It provides a
/// declarative way to integrate onboarding into your app's view hierarchy.
public extension View {
    /// Conditionally shows onboarding content if the user hasn't completed it yet.
    ///
    /// This modifier wraps your view and automatically displays the onboarding screen
    /// when needed, or shows your original content when onboarding is complete.
    /// The onboarding state is automatically managed using AppStorage.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// ContentView()
    ///     .showOnboardingIfNeeded(
    ///         config: OnboardingConfiguration.apple(
    ///             appDisplayName: "My App",
    ///             appIcon: Image("AppIcon"),
    ///             privacyPolicyURL: URL(string: "https://example.com/privacy"),
    ///             features: myFeatures
    ///         )
    ///     )
    /// ```
    ///
    /// ## Custom Continue Action
    ///
    /// ```swift
    /// ContentView()
    ///     .showOnboardingIfNeeded(
    ///         config: config,
    ///         continueAction: {
    ///             // Custom logic before marking as complete
    ///             analytics.track("onboarding_completed")
    ///             // Onboarding will be marked complete automatically
    ///         }
    ///     )
    /// ```
    ///
    /// - Parameters:
    ///   - storage: The AppStorage property for tracking completion state (defaults to `.onboarding`)
    ///   - config: Configuration for customizing the onboarding experience
    ///   - continueAction: Optional custom action to perform when continuing (defaults to marking complete)
    ///
    /// - Returns: A modified view that conditionally shows onboarding content
    func showOnboardingIfNeeded(
        storage: AppStorage<Bool> = .onboarding,
        config: OnboardingConfiguration,
        continueAction: (() -> Void)? = nil
    ) -> some View {
        modifier(
            OnboardingModifier<EmptyView>(
                storage: storage,
                config: config,
                continueAction: continueAction,
                flowContent: nil
            )
        )
    }

    /// Conditionally shows onboarding content if the user hasn't completed it yet, then performs a custom onboarding flow.
    ///
    /// This overload allows you to present a custom "flow" after the initial onboarding welcome screen is completed.
    /// The `flowContent` closure is displayed after the user continues on the welcome screen but before onboarding is marked complete.
    /// This enables richer onboarding experiences such as personal setup steps, permissions prompts, tutorials, etc.
    ///
    /// ## Usage
    /// ```swift
    /// ContentView()
    ///     .showOnboardingIfNeeded(
    ///         config: config,
    ///         flowContent: {
    ///             MyOnboardingSetupView(onFinish: { ... })
    ///         }
    ///     )
    /// ```
    ///
    /// - Parameters:
    ///   - storage: The AppStorage property for tracking completion state (defaults to `.onboarding`)
    ///   - config: Configuration for customizing the onboarding experience
    ///   - continueAction: Optional custom action to perform when continuing (defaults to marking complete)
    ///   - flowContent: A view builder for displaying custom content after the welcome screen but before marking onboarding complete
    ///
    /// - Returns: A modified view that conditionally shows onboarding content followed by a custom flow
    func showOnboardingIfNeeded<F: View>(
        storage: AppStorage<Bool> = .onboarding,
        config: OnboardingConfiguration,
        continueAction: (() -> Void)? = nil,
        @ViewBuilder flowContent: @escaping () -> F
    ) -> some View {
        modifier(
            OnboardingModifier<F>(
                storage: storage,
                config: config,
                continueAction: continueAction,
                flowContent: flowContent
            )
        )
    }
}

struct OnboardingModifier<F: View> {
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
}

extension OnboardingModifier: ViewModifier {
    func body(content: Content) -> some View {
        if isOnboardingCompleted {
            content
        } else if let flowContent, isWelcomeScreenCompleted {
            flowContent()
        } else {
            welcomeScreen()
        }
    }
}

@MainActor
private extension OnboardingModifier {
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
    .showOnboardingIfNeeded(
        config: .mock
    )
}

#Preview("Welcome Screen with Flow") {
    VStack {
        Spacer()
    }
    .showOnboardingIfNeeded(
        config: .mock,
        flowContent: {
            Text("Flow Content")
        }
    )
}
