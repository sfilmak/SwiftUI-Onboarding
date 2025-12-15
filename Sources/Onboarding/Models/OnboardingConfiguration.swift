//
//  OnboardingConfiguration.swift
//
//  Created by James Sedlacek on 12/30/23.
//

import SwiftUI

/// Configuration model for customizing the onboarding experience.
///
/// `OnboardingConfiguration` provides a centralized way to customize the appearance
/// and content of the onboarding flow. It includes visual styling options, feature
/// content, and layout preferences.
///
/// ## Usage
///
/// ```swift
/// let config = OnboardingConfiguration.apple(
///     accentColor: .blue,
///     appDisplayName: "My App",
///     appIcon: Image("AppIcon"),
///     features: [
///         FeatureInfo(
///             image: Image(systemName: "star.fill"),
///             title: "Amazing Feature",
///             content: "This feature will change your life!"
///         )
///     ],
///     privacyPolicyURL: URL(string: "https://example.com/privacy"),
///     titleSectionAlignment: .center
/// )
/// ```
public struct OnboardingConfiguration {
    /// The welcome screen to render for the onboarding flow.
    public let welcomeScreen: WelcomeScreen

    /// Creates a new onboarding configuration.
    ///
    /// - Parameters:
    ///   - welcomeScreen: The welcome screen configuration to present.
    public init(welcomeScreen: WelcomeScreen) {
        self.welcomeScreen = welcomeScreen
    }
}

@MainActor
public extension OnboardingConfiguration {
    /// Factory for the Apple-style welcome screen.
    ///
    /// - Parameters:
    ///   - accentColor: The primary accent color (defaults to blue)
    ///   - appDisplayName: The display name of the app
    ///   - appIcon: The app icon to display on the welcome screen
    ///   - features: Array of features to showcase
    ///   - privacyPolicyURL: Link to the privacy policy to be opened from the welcome screen
    ///   - titleSectionAlignment: Alignment for the title section (defaults to leading)
    static func apple(
        accentColor: Color = .blue,
        appDisplayName: String,
        appIcon: Image,
        features: [FeatureInfo],
        privacyPolicyURL: URL? = nil,
        titleSectionAlignment: HorizontalAlignment = .leading
    ) -> Self {
        .init(
            welcomeScreen: .apple(
                .init(
                    accentColor: accentColor,
                    appDisplayName: appDisplayName,
                    appIcon: appIcon,
                    features: features,
                    privacyPolicyURL: privacyPolicyURL,
                    titleSectionAlignment: titleSectionAlignment
                )
            )
        )
    }

    static let mock = Self.apple(
        appDisplayName: .init("Onboarding"),
        appIcon: Image(.onboardingKitMockAppIcon),
        features: [.mock, .mock2, .mock3, .mock4, .mock5, .mock6],
        privacyPolicyURL: URL(string: "https://example.com/privacy")
    )
}
