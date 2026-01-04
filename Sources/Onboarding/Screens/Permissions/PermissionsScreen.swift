//
//  PermissionsScreen.swift
//
//  Created by James Sedlacek on 12/17/25.
//

import SwiftUI
import UserNotifications

/// Defines available permission priming screens.
@MainActor
public enum PermissionsScreen {
    case notifications(NotificationsPriming.Configuration)
}

public extension PermissionsScreen {
    static func notifications(
        accentColor: Color = .blue,
        title: LocalizedStringKey = .notificationsTitleDefault,
        subtitle: LocalizedStringKey,
        appIcon: Image? = nil,
        authorizationOptions: UNAuthorizationOptions = [.alert, .badge, .sound],
        allowAction: @escaping () -> Void = {},
        skipAction: (() -> Void)? = nil,
        failureAction: ((_ granted: Bool, _ error: Error?) -> Void)? = nil,
        bundle: Bundle? = nil
    ) -> Self {
        .notifications(
            .init(
                accentColor: accentColor,
                title: title,
                subtitle: subtitle,
                appIcon: appIcon,
                authorizationOptions: authorizationOptions,
                allowAction: allowAction,
                skipAction: skipAction,
                failureAction: failureAction,
                bundle: bundle
            )
        )
    }

    func with(
        allowAction: @escaping () -> Void,
        skipAction: (() -> Void)? = nil,
        failureAction: ((_ granted: Bool, _ error: Error?) -> Void)? = nil
    ) -> Self {
        switch self {
        case let .notifications(configuration):
            return .notifications(
                configuration.with(
                    allowAction: allowAction,
                    skipAction: skipAction,
                    failureAction: failureAction
                )
            )
        }
    }
}

@MainActor
public extension PermissionsScreen {
    static let mock: Self = .notifications(.mock)
}

@MainActor
extension PermissionsScreen: View {
    public var body: some View {
        switch self {
        case let .notifications(configuration):
            NotificationsPriming(config: configuration)
        }
    }
}

#Preview {
    PermissionsScreen.mock
}
