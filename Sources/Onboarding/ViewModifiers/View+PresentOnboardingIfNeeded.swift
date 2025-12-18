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
    /// Provide your onboarding view via the `onboardingContent` builder. Call the supplied
    /// `markComplete` action when onboarding finishes to dismiss the sheet and reveal
    /// your main content.
    ///
    /// - Parameters:
    ///   - storage: The AppStorage property for tracking completion state (defaults to `.onboarding`)
    ///   - onboardingContent: Builder that returns the onboarding UI. Receives a `markComplete` action.
    ///
    /// - Returns: A view that presents onboarding in a sheet when needed
    func presentOnboardingIfNeeded<Onboarding: View>(
        storage: AppStorage<Bool> = .onboarding,
        @ViewBuilder onboardingContent: @escaping (_ markComplete: @escaping () -> Void) -> Onboarding
    ) -> some View {
        modifier(
            OnboardingSheetModifier(
                storage: storage,
                onboardingContent: onboardingContent
            )
        )
    }
}

@MainActor
private struct OnboardingSheetModifier<Onboarding: View> {
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

extension OnboardingSheetModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .sheet(
                isPresented: $isOnboardingCompleted.inverse,
                onDismiss: markComplete,
                content: sheetContent
            )
    }

    @ViewBuilder
    private func sheetContent() -> some View {
        onboardingContent(markComplete)
            .interactiveDismissDisabled(true)
    }
}

#Preview("Welcome Screen Only") {
    VStack {
        Spacer()
    }
    .presentOnboardingIfNeeded(
        onboardingContent: { markComplete in
            WelcomeScreen.mock.with(continueAction: markComplete)
        }
    )
}

#Preview("Welcome Screen with Flow") {
    VStack {
        Spacer()
    }
    .presentOnboardingIfNeeded(
        onboardingContent: { markComplete in
            WelcomeScreen.mock.with(continueAction: markComplete)
        }
    )
}
