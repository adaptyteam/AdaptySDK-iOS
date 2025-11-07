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
<a href="https://adapty.io/docs/sdk-installation-ios#install-adapty-sdk?utm_source=github&utm_medium=referral&utm_campaign=AdaptySDK-iOS"><img src="https://img.shields.io/badge/SwiftPM-compatible-orange.svg"></a>
</p>

![Adapty: CRM for mobile apps with subscriptions](https://adapty-portal-media-production.s3.amazonaws.com/github/adapty-schema.png)

Adapty SDK is an open-source framework that makes implementing in-app subscriptions for iOS fast and easy. It’s 100% open-source, native, and lightweight.

## Why Adapty?

- [No server code implementation](https://docs.adapty.io/v3.0/docs/ios-installation?utm_source=github&utm_medium=referral&utm_campaign=AdaptySDK-iOS). ntegrate in-app purchases with server-side receipt validation in minutes — in your own paywall or one created in the no-code builder.
- [No-code paywall builder](https://adapty.io/docs/adapty-paywall-builder). Create a beautiful, natively rendered paywall in the no-code editor and display it in your app to start getting paid instantly.
- [On-the-fly paywalls price testing](https://docs.adapty.io/v3.0/docs/ab-tests?utm_source=github&utm_medium=referral&utm_campaign=AdaptySDK-iOS). Test different prices, duration, offers, messages, and designs simultaneously, all without new app releases.
- [Beautiful onboardings](https://adapty.io/docs/onboardings). Design onboardings in the no-code editor and guide users through their first app experience.
- [Full customer's payment history](https://docs.adapty.io/v3.0/docs/profiles-crm?utm_source=github&utm_medium=referral&utm_campaign=AdaptySDK-iOS). Explore the user's payment events from the trial start to subscription cancellation or billing issues.
- [3rd-party integrations](https://docs.adapty.io/v3.0/docs/events?utm_source=github&utm_medium=referral&utm_campaign=AdaptySDK-iOS). Send subscription events to 3rd-party analytics, attribution, and ad services with no coding, even if the user uninstalls the app.
- [Advanced analytics](https://docs.adapty.io/v3.0/docs/charts?utm_source=github&utm_medium=referral&utm_campaign=AdaptySDK-iOS). Analyze your app real-time metrics with advanced filters, such as Ad network, Ad campaign, country, A/B test, etc.

<h3 align="center" style="border-bottom: none; margin-top: -15px; margin-bottom: -15px; font-size: 150%">
<a href="https://adapty.io/schedule-demo?utm_source=github&utm_medium=referral&utm_campaign=AdaptySDK-iOS_schedule-demo">Talk to Us to Learn More</a>
</h3>

## Integrate IAPs Within a few hours without server coding

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

## Design paywalls in the no-code builder

![No-code builder](https://adapty.io/assets/uploads/2024/09/img-builder-and-templates@2x.webp)

With Adapty, you can create a complete, purchase-ready paywall in the no-code builder. 

Adapty automatically renders it and handles all the complex purchase flow, receipt validation, and subscription management behind the scenes.

## Test paywalls & prices on iOS without app releases

![Adapty: In-app subscriptions with paywall A/B testing](https://adapty-portal-media-production.s3.amazonaws.com/github/ab-test-new.png)

- Optimize in-app subscriptions with the paywall A/B testing. Conversions, trials, revenue, cancellations, and more — everything is calculated for you: each paywall and each A/B test.
- Change images, colors, layouts, and literally anything using the no-code builder or a custom JSON. Configure different prices, trial periods, promo offers, and more in Adapty without app releases.

## Real-time analytics for your iOS app

![Adapty: How Adapty works](https://adapty-portal-media-production.s3.amazonaws.com/github/analyticss.gif)

- Manage the subscription's state without managing transactions.
- 99.5% accuracy with App Store Connect.
- View and analyze data by attributes, such as status, channels, campaigns, and more.
- Filter, group, and measure metrics by attribution, platform, custom users' segments, and more in a few clicks.

## Adapty demo apps

[Here](Examples/), you can find a demo application for Adapty. Before running the app, you will need to configure the project.

## Mobile app monetization's largest community

Ask questions, participate in discussions about Adapty-related topics, become a part of our community for iOS app developers and marketers. Learn how to monetize your app, ask questions, post jobs, read industry news and analytics. Ad free.

<a href="https://discord.gg/subscriptions-hub"><img src="https://adapty-portal-media-production.s3.amazonaws.com/github/join-discord.svg" /></a>

## Get started

Follow our [quickstart guide](https://adapty.io/docs/ios-sdk-overview#get-started) to install and configure Adapty SDK. Set up purchases in hours instead of weeks 🚀

## Contributing

- Feel free to open an issue, we check all of them or drop us an email at [support@adapty.io](mailto:support@adapty.io) and tell us everything you want.
- Want to suggest a feature? Just contact us or open an issue in the repo.

## Like Adapty SDK?

So do we! Feel free to star the repo ⭐️⭐️⭐️ and make our developers happy!

## License

Adapty is available under the MIT license. [Click here](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/LICENSE) for details.
