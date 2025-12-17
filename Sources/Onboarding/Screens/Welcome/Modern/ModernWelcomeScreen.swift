//
//  ModernWelcomeScreen.swift
//
//  Created by James Sedlacek on 2/15/25.
//

import SwiftUI

@MainActor
public struct ModernWelcomeScreen {
    public struct Configuration {
        public let accentColor: Color
        public let appDisplayName: String
        public let appIcon: Image
        public let features: [FeatureInfo]
        public let termsOfServiceURL: URL
        public let privacyPolicyURL: URL
        public let continueAction: () -> Void

        public init(
            accentColor: Color = .blue,
            appDisplayName: String,
            appIcon: Image,
            features: [FeatureInfo],
            termsOfServiceURL: URL,
            privacyPolicyURL: URL,
            continueAction: @escaping () -> Void = {}
        ) {
            self.accentColor = accentColor
            self.appDisplayName = appDisplayName
            self.appIcon = appIcon
            self.features = features
            self.termsOfServiceURL = termsOfServiceURL
            self.privacyPolicyURL = privacyPolicyURL
            self.continueAction = continueAction
        }

        func with(continueAction: @escaping () -> Void) -> Self {
            .init(
                accentColor: accentColor,
                appDisplayName: appDisplayName,
                appIcon: appIcon,
                features: features,
                termsOfServiceURL: termsOfServiceURL,
                privacyPolicyURL: privacyPolicyURL,
                continueAction: continueAction
            )
        }
    }

    private let config: Configuration
    @State private var isAnimating = false

    public init(config: Configuration) {
        self.config = config
    }

    private func onAppear() {
        Animation.welcomeScreen.deferred {
            isAnimating = true
        }
    }
}

@MainActor
public extension ModernWelcomeScreen.Configuration {
    static let mock = Self(
        appDisplayName: .init("Onboarding"),
        appIcon: Image(.mockAppIconResource),
        features: [.mock, .mock2, .mock3, .mock4, .mock5, .mock6],
        termsOfServiceURL: URL(string: "https://example.com/terms")!,
        privacyPolicyURL: URL(string: "https://example.com/privacy")!
    )
}

@MainActor
extension ModernWelcomeScreen: View {
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                heroSection
                featureCards
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 28)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom, content: bottomSection)
        .onAppear(perform: onAppear)
        .dynamicTypeSize(.xSmall ... .xxxLarge)
    }

    private var heroSection: some View {
        VStack(spacing: 12) {
            config.appIcon
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: config.accentColor.opacity(0.28), radius: 12, y: 6)
                .scaleEffect(isAnimating ? 1 : 0.85)
                .opacity(isAnimating ? 1 : 0)

            Text("Welcome to")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(config.appDisplayName)
                .font(.largeTitle.weight(.bold))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var featureCards: some View {
        VStack(spacing: 12) {
            ForEach(Array(config.features.enumerated()), id: \.offset) { _, feature in
                featureCard(feature)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    private func featureCard(_ feature: FeatureInfo) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                feature.image
                    .font(.title2.weight(.semibold))
                    .frame(width: 40, height: 40)
                    .background(
                        .background.tertiary,
                        in: .rect(cornerRadius: 12)
                    )
                    .foregroundStyle(config.accentColor)

                VStack(alignment: .leading, spacing: 6) {
                    Text(feature.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(feature.content)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
        .padding(16)
        .background(
            .background.secondary,
            in: .rect(cornerRadius: 12)
        )
    }

    private var disclaimerSection: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("By continuing you agree to our")
                .font(.footnote)
                .foregroundStyle(.secondary)

            HStack(spacing: 4) {
                Link("terms of service", destination: config.termsOfServiceURL)
                    .font(.footnote.weight(.semibold))
                Text("and")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Link("privacy policy", destination: config.privacyPolicyURL)
                    .font(.footnote.weight(.semibold))
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 4)
    }

    private func bottomSection() -> some View {
        VStack(alignment: .center, spacing: 16) {
            disclaimerSection

            Button(action: config.continueAction) {
                Text("Continue")
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .font(.title3.weight(.medium))
            }
            .buttonStyle(.borderedProminent)
            .tint(config.accentColor)
        }
        .padding(20)
        .background(.background.tertiary)
    }
}

#Preview("Modern") {
    ModernWelcomeScreen(config: .mock)
}
