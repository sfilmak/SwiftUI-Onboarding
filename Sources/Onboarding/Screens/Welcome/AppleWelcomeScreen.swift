//
//  AppleWelcomeScreen.swift
//
//  Created by James Sedlacek on 12/30/23.
//

import SwiftUI

@MainActor
public struct AppleWelcomeScreen {
    public struct Configuration {
        public let accentColor: Color
        public let appDisplayName: String
        public let features: [FeatureInfo]
        public let titleSectionAlignment: HorizontalAlignment

        public init(
            accentColor: Color = .blue,
            appDisplayName: String,
            features: [FeatureInfo],
            titleSectionAlignment: HorizontalAlignment = .leading
        ) {
            self.accentColor = accentColor
            self.appDisplayName = appDisplayName
            self.features = features
            self.titleSectionAlignment = titleSectionAlignment
        }
    }

    private let config: Configuration
    private let appIcon: Image
    private let continueAction: () -> Void
    private let dataPrivacyContent: () -> AnyView
    private let signInWithAppleConfiguration: SignInWithAppleButtonConfiguration?
    @State private var isAnimating = false

    public init<C: View>(
        config: Configuration,
        appIcon: Image,
        continueAction: @escaping () -> Void,
        @ViewBuilder dataPrivacyContent: @escaping () -> C,
        signInWithAppleConfiguration: SignInWithAppleButtonConfiguration? = nil
    ) {
        self.config = config
        self.appIcon = appIcon
        self.continueAction = continueAction
        self.dataPrivacyContent = { AnyView(dataPrivacyContent()) }
        self.signInWithAppleConfiguration = signInWithAppleConfiguration
    }

    private func onAppear() {
        Animation.welcomeScreen.deferred {
            isAnimating = true
        }
    }
}

@MainActor
public extension AppleWelcomeScreen.Configuration {
    static let mock = Self(
        appDisplayName: .init("Onboarding"),
        features: [.mock, .mock2, .mock3, .mock4, .mock5, .mock6]
    )
}

@MainActor
extension AppleWelcomeScreen: View {
    public var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 40) {
                titleSection
                featureSection
            }
            .padding(.vertical, 24)
        }
        .scrollIndicators(.hidden)
        .defaultScrollAnchor(.center, for: .alignment)
        .scrollBounceBehavior(.basedOnSize)
        .background(.background.secondary)
        .safeAreaInset(edge: .bottom, content: bottomSection)
        .onAppear(perform: onAppear)
        .dynamicTypeSize(.xSmall ... .xxxLarge)
    }

    private var titleSection: some View {
        TitleSection(
            config: config,
            appIcon: appIcon,
            shouldHideAppIcon: !isAnimating
        )
        .offset(y: isAnimating ? 0 : 200)
    }

    private var featureSection: some View {
        FeatureSection(config: config)
            .opacity(isAnimating ? 1 : 0)
            .padding(.horizontal, 48)
    }

    private func bottomSection() -> some View {
        BottomSection(
            accentColor: config.accentColor,
            appDisplayName: config.appDisplayName,
            continueAction: continueAction,
            signInWithAppleConfiguration: signInWithAppleConfiguration,
            dataPrivacyContent: dataPrivacyContent
        )
    }
}

#Preview("Default") {
    AppleWelcomeScreen(
        config: .mock,
        appIcon: Image(.onboardingKitMockAppIcon),
        continueAction: {
            print("Continue Tapped")
        },
        dataPrivacyContent: {
            Text("Privacy Policy Content")
        }
    )
}

#Preview("Sign in with Apple") {
    AppleWelcomeScreen(
        config: .mock,
        appIcon: Image(.onboardingKitMockAppIcon),
        continueAction: {
            print("Continue Tapped")
        },
        dataPrivacyContent: {
            Text("Privacy Policy Content")
        },
        signInWithAppleConfiguration: .init(
            onRequest: { _ in },
            onCompletion: { _ in }
        )
    )
}
