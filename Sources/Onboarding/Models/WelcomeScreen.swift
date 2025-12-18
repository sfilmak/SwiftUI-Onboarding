//
//  WelcomeScreen.swift
//
//  Created by James Sedlacek on 1/20/25.
//

import SwiftUI

/// Defines the available welcome screen presentations for onboarding.
public enum WelcomeScreen {
    case apple(AppleWelcomeScreen.Configuration)
    case modern(ModernWelcomeScreen.Configuration)
}

public extension WelcomeScreen {
    static func apple(
        accentColor: Color = .blue,
        appDisplayName: String,
        appIcon: Image,
        features: [FeatureInfo],
        privacyPolicyURL: URL? = nil,
        titleSectionAlignment: HorizontalAlignment = .leading
    ) -> Self {
        .apple(
            .init(
                accentColor: accentColor,
                appDisplayName: appDisplayName,
                appIcon: appIcon,
                features: features,
                privacyPolicyURL: privacyPolicyURL,
                titleSectionAlignment: titleSectionAlignment
            )
        )
    }

    static func modern(
        accentColor: Color = .blue,
        appDisplayName: String,
        appIcon: Image,
        features: [FeatureInfo],
        termsOfServiceURL: URL,
        privacyPolicyURL: URL
    ) -> Self {
        .modern(
            .init(
                accentColor: accentColor,
                appDisplayName: appDisplayName,
                appIcon: appIcon,
                features: features,
                termsOfServiceURL: termsOfServiceURL,
                privacyPolicyURL: privacyPolicyURL
            )
        )
    }

    func with(continueAction: @escaping () -> Void) -> Self {
        switch self {
        case let .apple(configuration):
            return .apple(configuration.with(continueAction: continueAction))
        case let .modern(configuration):
            return .modern(configuration.with(continueAction: continueAction))
        }
    }
}

@MainActor
public extension WelcomeScreen {
    static let mock: Self = .apple(.mock)
}

@MainActor
extension WelcomeScreen: View {
    public var body: some View {
        switch self {
        case let .apple(configuration):
            AppleWelcomeScreen(config: configuration)
        case let .modern(configuration):
            ModernWelcomeScreen(config: configuration)
        }
    }
}
