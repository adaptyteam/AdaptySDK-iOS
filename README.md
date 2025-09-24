<h1 align="center" style="border-bottom: none">
<b>
    <a href="https://adapty.io/?utm_source=github&utm_medium=referral&utm_campaign=AdaptySDK-iOS">
        <img src="https://adapty-portal-media-production.s3.amazonaws.com/github/logo-adapty-new.svg">
    </a>
</b>
<br>Easy In-App Purchases Integration to
<br>Make Your iOS App Profitable
</h1>

<p align="center">
<a href="https://go.adapty.io/subhub-community-ios-rep"><img src="https://img.shields.io/badge/Adapty-discord-purple"></a>
<a href="http://bit.ly/3qXy7cf"><img src="https://img.shields.io/cocoapods/v/Adapty.svg?style=flat"></a>
<a href="https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/LICENSE"><img src="https://img.shields.io/cocoapods/l/Adapty.svg?style=flat"></a>
<a href="http://bit.ly/3qXy7cf2"><img src="https://img.shields.io/cocoapods/p/Adapty.svg?style=flat"></a>
<a href="https://docs.adapty.io/v2.0.0/docs/ios-sdk-installation#install-via-swift-package-manager?utm_source=github&utm_medium=referral&utm_campaign=AdaptySDK-iOS"><img src="https://img.shields.io/badge/SwiftPM-compatible-orange.svg"></a>
</p>

![Adapty: CRM for mobile apps with subscriptions](https://adapty-portal-media-production.s3.amazonaws.com/github/adapty-schema.png)

Adapty SDK is an open-source framework that makes implementing in-app subscriptions for iOS fast and easy. It’s 100% open-source, native, and lightweight.

## Why Adapty?

- [On-the-fly paywalls price testing](https://docs.adapty.io/v3.0/docs/ab-tests?utm_source=github&utm_medium=referral&utm_campaign=AdaptySDK-iOS). Test different prices, duration, offers, messages, and designs simultaneously, all without new app releases.
- [Full customer's payment history](https://docs.adapty.io/v3.0/docs/profiles-crm?utm_source=github&utm_medium=referral&utm_campaign=AdaptySDK-iOS). Explore the user's payment events from the trial start to subscription cancellation or billing issues.
- [In-app purchase data integration](https://docs.adapty.io/v3.0/docs/events?utm_source=github&utm_medium=referral&utm_campaign=AdaptySDK-iOS). Send subscription events to 3rd-party analytics, attribution, and ad services with no coding, even if the user uninstalls the app.
- [No server code implementation](https://docs.adapty.io/v3.0/docs/ios-installation?utm_source=github&utm_medium=referral&utm_campaign=AdaptySDK-iOS). Integrate in-app purchases with server-side receipt validation in minutes. Apple Promotional Offers supported out-of-the-box.
- [Advanced analytics](https://docs.adapty.io/v3.0/docs/charts?utm_source=github&utm_medium=referral&utm_campaign=AdaptySDK-iOS). Analyze your app real-time metrics with advanced filters, such as Ad network, Ad campaign, country, A/B test, etc.

<h3 align="center" style="border-bottom: none; margin-top: -15px; margin-bottom: -15px; font-size: 150%">
<a href="https://adapty.io/schedule-demo?utm_source=github&utm_medium=referral&utm_campaign=AdaptySDK-iOS_schedule-demo">Talk to Us to Learn More</a>
</h3>

## Integrate IAPs Within a Few Hours Without Server Coding

**Adapty handles everything, from free trials to refunds, in a simple, developer-friendly SDK.**

- Free trials, upgrades, downgrades, crossgrades, family sharing, renewals, promo offers, intro offers, promo codes, and more – Adapty SDK does everything with a single line of code.
- Easy subscription management.
- One-time purchases and lifetime subscriptions supported.
- Sync subscribers' states across iOS, Android, and Web.


```swift
// Your app’s code
import Adapty

Adapty.activate("YOUR_APP_KEY")

// Make a purchase, Adapty handles the rest
Adapty.makePurchase(product: product) { [weak self] result in
    switch result {
        case let .success(profile):
            // check access level
    case let .failure(error):
            // handle error
    }
}
```

## Price Testing for In-app Purchases on iOS Without App Releases

- Optimize in-app subscriptions with the paywall A/B testing. Conversions, trials, revenue, cancellations, and more — everything is calculated for you: each paywall and each A/B test.
- Change images, colors, layouts, and literally anything with a custom JSON. Configure different prices, trial periods, promo offers, and more in Adapty without app releases.

## Paywall A/B Testing on iOS

![Adapty: In-app subscriptions with paywall A/B testing](https://adapty-portal-media-production.s3.amazonaws.com/github/ab-test-new.png)

- Conversions, trials, revenue, cancellations, and more  everything is calculated for you: each paywall and each A/B test.
- Change images, colors, layouts and literally anything with a custom JSON.
- Price testing is seamlessly integrated for any platform.

## Real-time Analytics for Your iOS App

![Adapty: How Adapty works](https://adapty-portal-media-production.s3.amazonaws.com/github/analyticss.gif)

- Manage the subscription's state without managing transactions.
- 99.5% accuracy with App Store Connect.
- View and analyze data by attributes, such as status, channels, campaigns, and more.
- Filter, group, and measure metrics by attribution, platform, custom users' segments, and more in a few clicks.

## Adapty-Demo apps

[Here](Examples/) you can find a demo application for Adapty. Before running the app, you will need to configure the project.

## Mobile App Monetization's Largest Community

Ask questions, participate in discussions about Adapty-related topics, become a part of our community for iOS app developers and marketers. Learn how to monetize your app, ask questions, post jobs, read industry news and analytics. Ad free.

<a href="https://discord.gg/subscriptions-hub"><img src="https://adapty-portal-media-production.s3.amazonaws.com/github/join-discord.svg" /></a>

## Getting Started

### 1. [Installing the iOS SDK via CocoaPods or Swift Package Manager, importing and configuring it, then setting up the logging](https://docs.adapty.io/v3.0/docs/ios-installation)

In your `AppDelegate` class:
```swift
import Adapty
```

And add the following to `application(_:didFinishLaunchingWithOptions:):`
```swift
let configurationBuilder =
    AdaptyConfiguration
        .builder(withAPIKey: "PUBLIC_SDK_KEY")
        .with(observerMode: false)
        .with(customerUserId: "YOUR_USER_ID")
        .with(idfaCollectionDisabled: false)
        .with(ipAddressCollectionDisabled: false)

Adapty.activate(with: configurationBuilder) { error in
  // handle the error
}
```


### 2. [Fetching and displaying products for paywalls in your app](https://docs.adapty.io/v3.0/docs/fetch-paywalls-and-products)

The Adapty iOS SDK allows you to remotely configure the products that will be displayed in your app. This way you don't have to hardcode the products and can dynamically change offers or run A/B tests without having to release a new version of the app.

To fetch the paywall, you have to call `.getPaywall()` method:
```swift
Adapty.getPaywall(placementId: "YOUR_PLACEMENT_ID") { result in
    switch result {
        case let .success(paywall):
            // the requested paywall
        case let .failure(error):
            // handle the error
    }
}
```

Once you have the paywall, you can query the product array that corresponds to it:

```swift
Adapty.getPaywallProducts(paywall: paywall) { result in
    switch result {
    case let .success(products):
        // the requested products array
    case let .failure(error):
        // handle the error
    }
}
```

### 3. [Making and restoring mobile purchases](https://docs.adapty.io/v3.0/docs/making-purchases)

To make the purchase, you have to call `.makePurchase()` method:
```swift
let product = products.first

Adapty.makePurchase(product: product) { result in
    switch result {
    case let .success(info):
        // successful purchase
    case let .failure(error):
        // handle the error
    }
}
```

### 4. [Getting info about the user subscription status and granting access to the premium features of the app](https://docs.adapty.io/v3.0/docs/subscription-status)

With the Adapty iOS App SDK you don't have to hardcode product IDs to check the subscription status. You just have to verify that the user has an active access level. To do this, you have to call `.getProfile()` method:
```swift
Adapty.getProfile { result in
    if let profile = try? result.get(), 
       profile.accessLevels["premium"]?.isActive ?? false {
        // grant access to premium features
    }
}
```

### 5. [Identifying the users of your app](https://docs.adapty.io/v3.0/docs/identifying-users)

Adapty creates an internal profile ID for every user. But if you have your own authentification system, you should set your own Customer User ID. You can find the users by the Customer User ID in Profiles. It can be used in the server-side API and then sent to all integrations.

### 6. [Setting User Attributes](https://docs.adapty.io/v3.0/docs/setting-user-attributes)

You can set optional attributes such as email, phone number, etc, to the user of your app. You can then use attributes to create user segments or just view them in CRM.

### 7. [Error Handling](https://docs.adapty.io/v3.0/docs/ios-sdk-error-handling)

### 8. [Attribution Integration](https://docs.adapty.io/v3.0/docs/attribution-integration)

Adapty SDK supports AppsFlyer, Adjust, Branch, Facebook Ads, and Apple Search Ads.

### 9. [Analytics Integration](https://docs.adapty.io/v3.0/docs/analytics-integration)

Adapty sends all subscription events to analytical services, such as Amplitude, Mixpanel, and AppMetrica.

### 10. [SDK Models](https://docs.adapty.io/v3.0/docs/sdk-models)

## Contributing

- Feel free to open an issue, we check all of them or drop us an email at [support@adapty.io](mailto:support@adapty.io) and tell us everything you want.
- Want to suggest a feature? Just contact us or open an issue in the repo.

## Like Adapty SDK?

So do we! Feel free to star the repo ⭐️⭐️⭐️ and make our developers happy!

## License

Adapty is available under the MIT license. [Click here](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/LICENSE) for details.
