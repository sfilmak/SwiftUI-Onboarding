//
//  WelcomeScreen.swift
//
//  Created by James Sedlacek on 1/20/25.
//

import SwiftUI

/// Defines the available welcome screen presentations for onboarding.
public enum WelcomeScreen {
    case apple(AppleWelcomeScreen.Configuration)
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

    func with(continueAction: @escaping () -> Void) -> Self {
        switch self {
        case let .apple(configuration):
            return .apple(configuration.with(continueAction: continueAction))
        }
    }
}

@MainActor
public extension WelcomeScreen {
    static let mock: Self = .apple(.mock)
}
