//
//  NotificationsPriming.swift
//
//  Created by James Sedlacek on 12/17/25.
//

import SwiftUI
import UserNotifications

/// A focused priming screen to encourage enabling push notifications.
@MainActor
public struct NotificationsPriming {
    /// Configuration for the notifications priming screen.
    @MainActor
    public struct Configuration {
        public let accentColor: Color
        public let title: LocalizedStringKey
        public let subtitle: LocalizedStringKey
        public let statusTime: LocalizedStringKey
        public let notificationTitle: LocalizedStringKey
        public let notificationBody: LocalizedStringKey
        public let notificationTimestamp: LocalizedStringKey
        public let allowButtonTitle: LocalizedStringKey
        public let skipButtonTitle: LocalizedStringKey?
        public let appIcon: Image?
        public let authorizationOptions: UNAuthorizationOptions
        public let allowAction: () -> Void
        public let skipAction: (() -> Void)?
        public let failureAction: ((_ granted: Bool, _ error: Error?) -> Void)?
        public let bundle: Bundle?

        public init(
            accentColor: Color = .blue,
            title: LocalizedStringKey = .notificationsTitleDefault,
            subtitle: LocalizedStringKey,
            statusTime: LocalizedStringKey = .notificationsStatusTime,
            notificationTitle: LocalizedStringKey = .notificationsNotificationTitle,
            notificationBody: LocalizedStringKey = .notificationsNotificationBody,
            notificationTimestamp: LocalizedStringKey = .notificationsNotificationTimestamp,
            allowButtonTitle: LocalizedStringKey = .notificationsAllowButton,
            skipButtonTitle: LocalizedStringKey? = .notificationsSkipButton,
            appIcon: Image? = nil,
            authorizationOptions: UNAuthorizationOptions = [.alert, .badge, .sound],
            allowAction: @escaping () -> Void = {},
            skipAction: (() -> Void)? = {},
            failureAction: ((_ granted: Bool, _ error: Error?) -> Void)? = nil,
            bundle: Bundle?
        ) {
            self.accentColor = accentColor
            self.title = title
            self.subtitle = subtitle
            self.statusTime = statusTime
            self.notificationTitle = notificationTitle
            self.notificationBody = notificationBody
            self.notificationTimestamp = notificationTimestamp
            self.allowButtonTitle = allowButtonTitle
            self.skipButtonTitle = skipButtonTitle
            self.appIcon = appIcon
            self.authorizationOptions = authorizationOptions
            self.allowAction = allowAction
            self.skipAction = skipAction
            self.failureAction = failureAction
            self.bundle = bundle
        }

        func with(
            allowAction: @escaping () -> Void,
            skipAction: (() -> Void)? = nil,
            failureAction: ((_ granted: Bool, _ error: Error?) -> Void)? = nil
        ) -> Self {
            .init(
                accentColor: accentColor,
                title: title,
                subtitle: subtitle,
                statusTime: statusTime,
                notificationTitle: notificationTitle,
                notificationBody: notificationBody,
                notificationTimestamp: notificationTimestamp,
                allowButtonTitle: allowButtonTitle,
                skipButtonTitle: skipButtonTitle,
                appIcon: appIcon,
                authorizationOptions: authorizationOptions,
                allowAction: allowAction,
                skipAction: skipAction,
                failureAction: failureAction ?? self.failureAction,
                bundle: bundle
            )
        }
    }

    let config: Configuration
    @State var isAnimating = false
    @State var isLoading = false

    public init(config: Configuration) {
        self.config = config
    }

    func onAppear() {
        Animation.welcomeScreen.deferred {
            isAnimating = true
        }
    }

    func requestAuthorizationAndProceed() {
        isLoading = true
        Task {
            defer { isLoading = false }

            do {
                let granted = try await UNUserNotificationCenter.current()
                    .requestAuthorization(options: config.authorizationOptions)
                if granted {
                    config.allowAction()
                } else {
                    config.failureAction?(false, nil)
                }
            } catch {
                config.failureAction?(false, error)
            }
        }
    }
}

@MainActor
public extension NotificationsPriming.Configuration {
    static let mock = Self(
        subtitle: .notificationsSubtitleDefault,
        appIcon: Image(.mockAppIconResource),
        bundle: .module
    )
}
