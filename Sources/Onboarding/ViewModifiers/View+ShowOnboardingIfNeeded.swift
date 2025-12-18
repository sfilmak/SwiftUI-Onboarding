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
    /// Provide your onboarding view via the `onboardingContent` builder. Call the supplied
    /// `markComplete` action when onboarding finishes to reveal your main content.
    ///
    /// - Parameters:
    ///   - storage: The AppStorage property for tracking completion state (defaults to `.onboarding`)
    ///   - onboardingContent: Builder that returns the onboarding UI. Receives a `markComplete` action.
    ///
    /// - Returns: A modified view that conditionally shows onboarding content
    func showOnboardingIfNeeded<Onboarding: View>(
        storage: AppStorage<Bool> = .onboarding,
        @ViewBuilder onboardingContent: @escaping (_ markComplete: @escaping () -> Void) -> Onboarding
    ) -> some View {
        modifier(
            OnboardingModifier(
                storage: storage,
                onboardingContent: onboardingContent
            )
        )
    }
}

struct OnboardingModifier<Onboarding: View> {
    private let onboardingContent: (@escaping () -> Void) -> Onboarding
    @AppStorage private var isOnboardingCompleted: Bool

    init(
        storage: AppStorage<Bool>,
        onboardingContent: @escaping (@escaping () -> Void) -> Onboarding
    ) {
        self._isOnboardingCompleted = storage
        self.onboardingContent = onboardingContent
    }

    private func markComplete() {
        isOnboardingCompleted = true
    }
}

extension OnboardingModifier: ViewModifier {
    func body(content: Content) -> some View {
        Group {
            if isOnboardingCompleted {
                content
            } else {
                onboardingContent(markComplete)
            }
        }
    }
}

#Preview("Welcome Screen Only") {
    VStack {
        Spacer()
    }
    .showOnboardingIfNeeded(
        onboardingContent: { markComplete in
            WelcomeScreen.mock.with(continueAction: markComplete)
        }
    )
}

#Preview("Welcome Screen with Flow") {
    VStack {
        Spacer()
    }
    .showOnboardingIfNeeded(
        onboardingContent: { markComplete in
            WelcomeScreen.mock.with(continueAction: markComplete)
        }
    )
}
