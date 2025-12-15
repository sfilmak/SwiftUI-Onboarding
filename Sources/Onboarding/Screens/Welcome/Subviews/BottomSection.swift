//
//  BottomSection.swift
//  
//
//  Created by James Sedlacek on 12/30/23.
//

import SwiftUI

@MainActor
struct BottomSection {
    private let accentColor: Color
    private let appDisplayName: String
    private let privacyPolicyURL: URL?
    private let continueAction: () -> Void
    @State private var isAnimating: Bool = false
    @Environment(\.openURL) private var openURL

    init(
        accentColor: Color,
        appDisplayName: String,
        privacyPolicyURL: URL?,
        continueAction: @escaping () -> Void
    ) {
        self.accentColor = accentColor
        self.appDisplayName = appDisplayName
        self.privacyPolicyURL = privacyPolicyURL
        self.continueAction = continueAction
    }

    private func onAppear() {
        Animation.bottomSection.deferred {
            isAnimating = true
        }
    }

    private func disclosureAction() {
        guard let privacyPolicyURL else { return }
        openURL(privacyPolicyURL)
    }
}

@MainActor
extension BottomSection: View {
    var body: some View {
        VStack(alignment: .center, spacing: .zero) {
            dataPrivacyImage
            disclosureText
            continueButton
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 24)
        .background(.background.secondary)
        .mask(opacityLinearGradient)
        .opacity(isAnimating ? 1 : 0)
        .onAppear(perform: onAppear)
    }

    private var dataPrivacyImage: some View {
        Image(.onboardingKitDataPrivacy)
            .resizable()
            .foregroundStyle(accentColor)
            .frame(width: 40, height: 40)
    }

    private var disclosureText: some View {
        Button(action: disclosureAction) {
            Group {
                Text(verbatim: appDisplayName)
                    .foregroundStyle(.secondary) +
                Text(.privacyDataCollection, bundle: .module)
                    .foregroundStyle(.secondary) +
                Text(.privacyDataManagement, bundle: .module)
                    .foregroundStyle(accentColor)
                    .bold()
            }
            .multilineTextAlignment(.center)
            .font(.caption)
            .padding(.bottom, 24)
            .padding(.top, 6)
        }
        .disabled(privacyPolicyURL == nil)
    }

    private var continueButton: some View {
        Button(
            action: continueAction,
            label: continueText
        )
        .font(.title3.weight(.medium))
        .buttonStyle(.borderedProminent)
        .tint(accentColor)
    }

    private func continueText() -> some View {
        Text(.actionContinue, bundle: .module)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
    }

    private func opacityLinearGradient() -> some View {
        LinearGradient(
            colors: [.black.opacity(0.9), .black, .black, .black],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    VStack {
        Spacer()
    }
    .safeAreaInset(edge: .bottom) {
        BottomSection(
            accentColor: .blue,
            appDisplayName: .init("Test App"),
            privacyPolicyURL: URL(string: "https://example.com/privacy"),
            continueAction: {
                print("Continue Tapped")
            }
        )
    }
}
