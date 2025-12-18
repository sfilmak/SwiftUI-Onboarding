# SwiftUI-Onboarding

[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![GitHub stars](https://img.shields.io/github/stars/Sedlacek-Solutions/SwiftUI-Onboarding.svg)](https://github.com/Sedlacek-Solutions/SwiftUI-Onboarding/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/Sedlacek-Solutions/SwiftUI-Onboarding.svg?color=blue)](https://github.com/Sedlacek-Solutions/SwiftUI-Onboarding/network)
[![GitHub contributors](https://img.shields.io/github/contributors/Sedlacek-Solutions/SwiftUI-Onboarding.svg?color=blue)](https://github.com/Sedlacek-Solutions/SwiftUI-Onboarding/network)
<a href="https://github.com/Sedlacek-Solutions/SwiftUI-Onboarding/pulls"><img src="https://img.shields.io/github/issues-pr/Sedlacek-Solutions/SwiftUI-Onboarding" alt="Pull Requests Badge"/></a>
<a href="https://github.com/Sedlacek-Solutions/SwiftUI-Onboarding/issues"><img src="https://img.shields.io/github/issues/Sedlacek-Solutions/SwiftUI-Onboarding" alt="Issues Badge"/></a>

https://github.com/user-attachments/assets/ce319597-e5ba-434a-ab45-c66a6a7e501a

## Description
SwiftUI-Onboarding is a SwiftUI library that provides an Apple-like app onboarding experience.

## Features

- ✅ **Swift 6.0 Compatible** - Built for the latest Swift standards
- 🌍 **Multi-language Support** - 10 languages included out of the box
- ♿ **Accessibility First** - Full Dynamic Type support and accessibility features
- 🎨 **Highly Customizable** - Flexible configuration options
- 📱 **Cross-platform** - iOS and macOS support
- 🔄 **Modern SwiftUI** - Uses latest SwiftUI APIs and patterns
- 💾 **Automatic State Management** - Built-in AppStorage integration
- 🌗 **Light and Dark Mode** - Fully supports both light and dark appearance

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Supported Languages](#supported-languages)
- [Usage](#usage)
  - [Basic Setup](#basic-setup)
  - [Advanced Usage](#advanced-usage)
- [Configuration Options](#configuration-options)
- [Contributing](#contributing)
- [License](#license)

## Requirements

- **iOS**: 18.0 or later
- **macOS**: 15.0 or later
- **Swift**: 6.0 or later

## Installation

You can install `Onboarding` using the Swift Package Manager.

1. In Xcode, select "File" > "Add Package Dependencies"
2. Copy & paste the following into the "Search or Enter Package URL" search bar:
```https://github.com/Sedlacek-Solutions/SwiftUI-Onboarding.git```
3. Xcode will fetch the repository & the "Onboarding" library will be added to your project

## Supported Languages

Onboarding includes localization for the following languages:

- **English (en)**
- **German (de)** 
- **Spanish (es)**
- **French (fr)**
- **Italian (it)**
- **Japanese (ja)**
- **Korean (ko)**
- **Portuguese (pt)**
- **Russian (ru)**
- **Chinese Simplified (zh-Hans)**
- **Bulgarian (bg)**

## Usage

### Basic Setup

1. **Create your onboarding configuration:**
```swift
import Onboarding
import SwiftUI

extension WelcomeScreen {
    static let production = WelcomeScreen.apple(
        accentColor: .blue,
        appDisplayName: "My Amazing App",
        appIcon: Image("AppIcon"),
        features: [
            FeatureInfo(
                image: Image(systemName: "star.fill"),
                title: "Amazing Features",
                content: "Discover powerful tools that make your life easier."
            ),
            FeatureInfo(
                image: Image(systemName: "shield.fill"),
                title: "Privacy First",
                content: "Your data stays private and secure on your device."
            ),
            FeatureInfo(
                image: Image(systemName: "bolt.fill"),
                title: "Lightning Fast",
                content: "Optimized performance for the best user experience."
            )
        ],
        privacyPolicyURL: URL(string: "https://example.com/privacy"),
        titleSectionAlignment: .center
    )
}
```

`WelcomeScreen` conforms to `View`; render it directly inside the onboarding modifier and inject the continue action via `.with(continueAction:)`.

2. **Add onboarding to your app's root view:**
```swift
import Onboarding
import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .showOnboardingIfNeeded { markComplete in
                    WelcomeScreen.production
                        .with(continueAction: markComplete)
                }
        }
    }
}
```

### Advanced Usage

#### Custom Continue Action

You can provide a custom action to perform when the user taps "Continue":
```swift
ContentView()
    .showOnboardingIfNeeded { markComplete in
        WelcomeScreen.production.with(continueAction: {
            // Perform analytics, API calls, etc.
            Analytics.track("onboarding_completed")
            markComplete()
        })
    }
```

#### Custom Storage

Use a custom AppStorage key for tracking onboarding state:
```swift
@AppStorage("myCustomOnboardingKey") private var customOnboardingState = false

ContentView()
    .showOnboardingIfNeeded(storage: $customOnboardingState) { markComplete in
        WelcomeScreen.production
            .with(continueAction: markComplete)
    }
```

#### Manual State Management

Access the convenient AppStorage extension for manual control:
```swift
import Onboarding

struct SettingsView: View {
    @AppStorage(.onboardingKey) private var isOnboardingCompleted = false
    
    var body: some View {
        VStack {
            Button("Reset Onboarding") {
                isOnboardingCompleted = false
            }
        }
    }
}
```

#### Presenting Onboarding as a Modal Sheet

Present onboarding as a sheet above your main content, instead of replacing the root view:
```swift
import Onboarding
import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .presentOnboardingIfNeeded { markComplete in
                    WelcomeScreen.production
                        .with(continueAction: markComplete)
                }
        }
    }
}
```

#### Modern Welcome Screen

Use the modern layout with feature cards and inline terms/privacy links:
```swift
let modern = WelcomeScreen.modern(
    accentColor: .mint,
    appDisplayName: "My Amazing App",
    appIcon: Image("AppIcon"),
    features: [
        FeatureInfo(image: Image(systemName: "bolt.fill"), title: "Fast", content: "Optimized for speed."),
        FeatureInfo(image: Image(systemName: "shield.fill"), title: "Secure", content: "Your data stays private.")
    ],
    termsOfServiceURL: URL(string: "https://example.com/terms")!,
    privacyPolicyURL: URL(string: "https://example.com/privacy")!
)

ContentView()
    .showOnboardingIfNeeded { markComplete in
        modern.with(continueAction: markComplete)
    }
```

#### Multi-Screen Onboarding Flows

Need more than a single welcome screen? Build whatever flow you need inside the onboarding builder and call `markComplete()` when you're done.
```swift
.showOnboardingIfNeeded { markComplete in
    NavigationStack {
        CustomTutorialView(onFinish: markComplete)
    }
}
```

## Configuration Options

### WelcomeScreen

- `.apple(AppleWelcomeScreen.Configuration)`: Apple-style hero layout with feature list and continue controls.
  - Convenience factory: `WelcomeScreen.apple(...)` produces the Apple-style welcome screen configuration you see in the examples.
  - Required: `appIcon`, `appDisplayName`, `features`
  - Optional: `accentColor`, `privacyPolicyURL`, `titleSectionAlignment`
- `.modern(ModernWelcomeScreen.Configuration)`: Card-based feature layout with inline terms/privacy links.
  - Required: `appIcon`, `appDisplayName`, `features`, `termsOfServiceURL`, `privacyPolicyURL`
  - Optional: `accentColor`, `titleSectionAlignment`

### AppleWelcomeScreen.Configuration

- `accentColor`: Primary color used throughout the onboarding (default: `.blue`)
- `appDisplayName`: Your app's display name shown in the welcome section
- `appIcon`: The app icon image
- `features`: Array of `FeatureInfo` objects to showcase
- `privacyPolicyURL`: URL to open when the privacy text is tapped
- `titleSectionAlignment`: Horizontal alignment for the title (`.leading`, `.center`, `.trailing`)

### FeatureInfo

- `image`: Icon representing the feature (typically SF Symbols)
- `title`: Brief, descriptive title
- `content`: Detailed description of the feature

## Contributing

We welcome contributions! 
Please feel free to submit a Pull Request. 
For major changes, please open an issue first to discuss what you would like to change.

## License

SwiftUI-Onboarding is available under the MIT license. See the LICENSE file for more info.
