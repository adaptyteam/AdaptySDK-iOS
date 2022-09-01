<h1 align="center" style="border-bottom: none">
<b>
    <a href="https://adapty.io/?utm_source=github&utm_medium=referral&utm_campaign=AdaptySDK-iOS">
        <img src="https://adapty-portal-media-production.s3.amazonaws.com/github/logo-adapty.png">
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
<a href="https://docs.adapty.io/docs/ios-sdk-installation#install-via-swift-package-manager?utm_source=github&utm_medium=referral&utm_campaign=AdaptySDK-iOS"><img src="https://img.shields.io/badge/SwiftPM-compatible-orange.svg"></a>
</p>

![Adapty: CRM for mobile apps with subscriptions](https://adapty-portal-media-production.s3.amazonaws.com/github/adapty-schema.png)

Adapty SDK is an open-source framework that makes implementing in-app subscriptions for iOS fast and easy. It’s 100% open-source, native, and lightweight.

## Why Adapty?

- [On-the-fly paywalls price testing](https://docs.adapty.io/docs/ab-test?utm_source=github&utm_medium=referral&utm_campaign=AdaptySDK-iOS). Test different prices, duration, offers, messages, and designs simultaneously, all without new app releases.
- [Full customer's payment history](https://docs.adapty.io/docs/profiles-crm?utm_source=github&utm_medium=referral&utm_campaign=AdaptySDK-iOS). Explore the user's payment events from the trial start to subscription cancellation or billing issues.
- [In-app purchase data integration](https://docs.adapty.io/docs/events?utm_source=github&utm_medium=referral&utm_campaign=AdaptySDK-iOS). Send subscription events to 3rd-party analytics, attribution, and ad services with no coding, even if the user uninstalls the app.
- [No server code implementation](https://docs.adapty.io/docs/ios-sdk-configuration?utm_source=github&utm_medium=referral&utm_campaign=AdaptySDK-iOS). Integrate in-app purchases with server-side receipt validation in minutes. Apple Promotional Offers supported out-of-the-box.
- [Advanced analytics](https://docs.adapty.io/docs/analytics-charts?utm_source=github&utm_medium=referral&utm_campaign=AdaptySDK-iOS). Analyze your app real-time metrics with advanced filters, such as Ad network, Ad campaign, country, A/B test, etc.
- [24/7 PRO support](#support).
- [Settings](#settings).

<h3 align="center" style="border-bottom: none; margin-top: -15px; margin-bottom: -15px; font-size: 150%">
<a href="https://adapty.io/schedule-demo?utm_source=github&utm_medium=referral&utm_campaign=AdaptySDK-iOS_schedule-demo">Schedule a Demo for Your Personal Onboarding</a>
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
Adapty.makePurchase(product: <product>, offerId: <offerid>) { (receipt, response, error) in
    if error == nil {
       // successful purchase
    }
}
```

## Price Testing for In-app Purchases on iOS Without App Releases

- Optimize in-app subscriptions with the paywall A/B testing. Conversions, trials, revenue, cancellations, and more — everything is calculated for you: each paywall and each A/B test.
- Change images, colors, layouts, and literally anything with a custom JSON. Configure different prices, trial periods, promo offers, and more in Adapty without app releases.

## Paywall A/B Testing on iOS

![Adapty: CRM for mobile apps with subscriptions](https://adapty-portal-media-production.s3.amazonaws.com/github/ab+test.png)

- Conversions, trials, revenue, cancellations, and more  everything is calculated for you: each paywall and each A/B test.
- Change images, colors, layouts and literally anything with a custom JSON.
- Price testing is seamlessly integrated for any platform.

## Real-time Analytics for Your iOS App

![Adapty: CRM for mobile apps with subscriptions](https://adapty-portal-media-production.s3.amazonaws.com/github/analytics.gif)

- Manage the subscription's state without managing transactions.
- 99.5% accuracy with App Store Connect.
- View and analyze data by attributes, such as status, channels, campaigns, and more.
- Filter, group, and measure metrics by attribution, platform, custom users' segments, and more in a few clicks.

## Support

Ask questions, participate in discussions about Adapty-related topics, become a part of our community for iOS app developers and marketers. Learn how to monetize your app, ask questions, post jobs, read industry news and analytics. Ad free.

<a href="https://discord.gg/subscriptions-hub"><img src="https://adapty-portal-media-production.s3.amazonaws.com/github/join-discord.svg" /></a>

## License

Adapty is available under the MIT license. [Click here](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/LICENSE) for details.

## Getting Started

- Read the [documentation](https://docs.adapty.io/docs/ios-sdk-installation?utm_source=github&utm_medium=referral&utm_campaign=AdaptySDK-iOS) to install and configure the Adapty iOS SDK. Set up purchases in hours instead of weeks.
- Feel free to open an issue, we check all of them. Or drop us an email at [support@adapty.io](mailto:support@adapty.io) and tell us everything you want.
- Want to suggest a feature? Just contact us or open an issue in the repo.

## Settings

### 1. [Installing the iOS SDK via CocoaPods or Swift Package Manager](https://docs.adapty.io/docs/ios-installation)
### 2. [Importing, configuring, and setting up the logging](https://docs.adapty.io/docs/ios-configuring)

In your `AppDelegate` class:
```swift
import Adapty
```

And add the following to `application(_:didFinishLaunchingWithOptions:):`
```swift
Adapty.activate("PUBLIC_SDK_KEY", customerUserId: "YOUR_USER_ID")
```

### 3. [Fetching and displaying products for paywalls in your app](https://docs.adapty.io/docs/ios-displaying-products)

The Adapty iOS SDK allows you to remotely configure the products that will be displayed in your app. This way you don't have to hardcode the products and can dynamically change offers or run A/B tests without having to release a new version of the app.

To fetch the products, you have to call `.getPaywalls()` method:
```swift
Adapty.getPaywalls(forceUpdate: Bool) { (paywalls, products, error) in
    if error == nil {
       // retrieve the products from paywalls
   }
}
```

### 4. [Making and restoring mobile purchases](https://docs.adapty.io/docs/ios-making-purchases)

To make the purchase, you have to call `.makePurchase()` method:
```swift
Adapty.makePurchase(product: <product>, offerId: <offerid>) { ( purchaseInfo, receipt, appleValidationResult, product, error) in
    if error == nil {
       // successful purchase
   }
}
```

### 5. [Getting info about the user subscription status and granting access to the premium features of the app](https://docs.adapty.io/docs/ios-subscription-status)

With the Adapty iOS App SDK you don't have to hardcode product IDs to check the subscription status. You just have to verify that the user has an active access level. To do this, you have to call `.getPurchaserInfo()` method:
```swift
Adapty.getPurchaseInfo(forceUpdate: Bool) { ( purchaseInfo, error) in
    if error == nil {
       // check the access
   }
}
```

### 6. [Identifying the users of your app](https://docs.adapty.io/docs/ios-identifying-users)

Adapty creates an internal profile ID for every user. But if you have your own authentification system, you should set your own Customer User ID. You can find the users by the Customer User ID in Profiles. It can be used in the server-side API and then sent to all integrations.

### 7. [Attribution Integration](https://docs.adapty.io/docs/attribution-integration)

Adapty SDK supports AppsFlyer, Adjust, Branch, Facebook Ads, and Apple Search Ads.

### 8. [Setting User Attributes](https://docs.adapty.io/docs/setting-user-attributes)

You can set optional attributes such as email, phone number, etc, to the user of your app. You can then use attributes to create user segments or just view them in CRM.

### 9. [Analytics Integration](https://docs.adapty.io/docs/analytics-integration)

Adapty sends all subscription events to analytical services, such as Amplitude, Mixpanel, and AppMetrica.

### 10. [Error Handling (SKError, NSError, Error)](https://docs.adapty.io/docs/ios-sdk-error-handling-skerror-nserror-error)

### 11. [SDK Models](https://docs.adapty.io/docs/ios-sdk-sdk-models)

## Like Adapty SDK? 

So do we! Feel free to star the repo ⭐️⭐️⭐️ and make our developers happy!

