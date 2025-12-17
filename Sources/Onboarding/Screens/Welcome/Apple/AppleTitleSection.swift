//
//  AppleTitleSection.swift
//
//
//  Created by James Sedlacek on 12/30/23.
//

import SwiftUI

@MainActor
struct AppleTitleSection {
    private let config: AppleWelcomeScreen.Configuration
    private let isAppIconHidden: Bool
    @State private var isAnimating = false

    init(
        config: AppleWelcomeScreen.Configuration,
        isAppIconHidden: Bool
    ) {
        self.config = config
        self.isAppIconHidden = isAppIconHidden
    }

    private func onAppear() {
        Animation.titleSection.deferred {
            isAnimating = true
        }
    }
}

@MainActor
extension AppleTitleSection: View {
    var body: some View {
        VStack(alignment: config.titleSectionAlignment, spacing: 2) {
            appIconView
            welcomeToText
            appDisplayNameText
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: config.titleSectionAlignment.toAlignment
        )
        .padding(.horizontal, 64)
        .font(.largeTitle)
        .opacity(isAnimating ? 1 : 0)
        .scaleEffect(isAnimating ? 1.0 : 0.5)
        .onAppear(perform: onAppear)
    }

    @ViewBuilder
    private var appIconView: some View {
        if isAppIconHidden {
            config.appIcon
                .resizable()
                .frame(width: 60, height: 60)
                .clipShape(.rect(cornerRadius: 10))
                .padding(.bottom)
        }
    }

    private var welcomeToText: some View {
        Text(.onboardingWelcomeTo, bundle: .module)
            .foregroundStyle(.primary)
            .fontWeight(.semibold)
    }

    private var appDisplayNameText: some View {
        Text(config.appDisplayName)
            .foregroundStyle(config.accentColor)
            .fontWeight(.bold)
    }
}

#Preview {
    AppleTitleSection(
        config: .mock,
        isAppIconHidden: true
    )
}
