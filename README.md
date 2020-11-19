# Adapty iOS SDK

[![Version](https://img.shields.io/cocoapods/v/Adapty.svg?style=flat)](https://cocoapods.org/pods/Adapty)
[![License](https://img.shields.io/cocoapods/l/Adapty.svg?style=flat)](https://cocoapods.org/pods/Adapty)
[![Platform](https://img.shields.io/cocoapods/p/Adapty.svg?style=flat)](https://cocoapods.org/pods/Adapty)

![Adapty: Win back churned subscribers in your iOS app](https://raw.githubusercontent.com/adaptyteam/AdaptySDK-iOS/master/adapty.png)

* [Requirements](#requirements)
* [Installation](#installation)
  + [CocoaPods](#cocoapods)
  + [Swift Package Manager](#swift-package-manager)
* [Configure your app](#configure-your-app)
* [Debugging](#debugging)
* [Advanced usage](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/Documentation/AdvancedUsage.md)
  + [Observer mode](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/Documentation/AdvancedUsage.md#observer-mode)
  + [Convert anonymous user to identifiable user](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/Documentation/AdvancedUsage.md#convert-anonymous-user-to-identifiable-user)
  + [Logout user](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/Documentation/AdvancedUsage.md#logout-user)
  + [Attribution tracker integration](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/Documentation/AdvancedUsage.md#attribution-tracker-integration)
  + [Update your user attributes](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/Documentation/AdvancedUsage.md#update-your-user-attributes)
  + [Displaying products](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/Documentation/AdvancedUsage.md#displaying-products)
  + [Working with purchases](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/Documentation/AdvancedUsage.md#working-with-purchases)
  + [Subscription status](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/Documentation/AdvancedUsage.md#subscription-status)
  + [Promo campaigns](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/Documentation/AdvancedUsage.md#promo-campaigns)
  + [Method swizzling in Adapty](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/Documentation/AdvancedUsage.md#method-swizzling-in-adapty)
  + [SwiftUI](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/Documentation/AdvancedUsage.md#swiftui)
* [License](#license)

## Requirements

- iOS 9.0+
- Xcode 10.2+

You can also use Adapty SDK in Swift and Objective-C applications.

## Installation

### CocoaPods

1. Create a Podfile if you don't have one: `pod init`
2. Add Adapty to your Podfile: `pod 'Adapty', '~> 1.10.0'`
3. Save the file and run: `pod install`. This creates an `.xcworkspace` file for your app. Use this file for all future development on your application.

### Swift Package Manager

1. In Xcode go to `File` > `Swift Packages` > `Add Package Dependency...`
2. Enter `https://github.com/adaptyteam/AdaptySDK-iOS.git` 
3. Choose a version and click `Next` and Xcode will add the package dependency to your project.

## Configure your app

In your AppDelegate class:

```Swift
import Adapty
```

And add the following to `application(_:didFinishLaunchingWithOptions:)`:

```Swift
Adapty.activate("PUBLIC_SDK_KEY", customerUserId: "YOUR_USER_ID")
```

If your app doesn't have user IDs, you can use **`.activate("PUBLIC_SDK_KEY")`** or pass nil for the **`customerUserId`**. Anyway, you can update **`customerUserId`** later within [**`.identify()`** request](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/Documentation/AdvancedUsage.md#convert-anonymous-user-to-identifiable-user).

## Debugging

Adapty will log errors and other important information to help you understand what is going on. There are three levels available: **`verbose`**, **`errors`** and **`none`** in case you want a bit of a silence.
You can set this immediately in your app while testing, before you configure Adapty.

```Swift
Adapty.logLevel = .verbose
```

## Advanced usage

To get up and running with subscriptions and Adapty SDK follow our [Advanced usage section](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/Documentation/AdvancedUsage.md).

## License

Adapty is available under the MIT license. [See LICENSE](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/LICENSE) for details.
