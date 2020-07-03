# Adapty iOS SDK

[![Version](https://img.shields.io/cocoapods/v/Adapty.svg?style=flat)](https://cocoapods.org/pods/Adapty)
[![License](https://img.shields.io/cocoapods/l/Adapty.svg?style=flat)](https://cocoapods.org/pods/Adapty)
[![Platform](https://img.shields.io/cocoapods/p/Adapty.svg?style=flat)](https://cocoapods.org/pods/Adapty)

![Adapty: Win back churned subscribers in your iOS app](https://raw.githubusercontent.com/adaptyteam/AdaptySDK-iOS/master/adapty.png)

## Requirements

- iOS 9.0+
- Xcode 10.2+

You can also use Adapty SDK in Objective-C applications.

## Installation

### CocoaPods

1. Create a Podfile if you don't have one: `pod init`
2. Add Adapty to your Podfile: `pod 'Adapty', '~> 1.4.0'`
3. Save the file and run: `pod install`. This creates an `.xcworkspace` file for your app. Use this file for all future development on your application.

## Usage

### Configure your app

In your AppDelegate class:

```Swift
import Adapty
```

And add the following to `application(_:didFinishLaunchingWithOptions:)`:

```Swift
Adapty.activate("PUBLIC_SDK_KEY", customerUserId: "YOUR_USER_ID")
```

If your app doesn't have user IDs, you can use **`.activate("PUBLIC_SDK_KEY")`** or pass nil for the **`customerUserId`**. Anyway, you can update **`customerUserId`** later within **`.identify()`** request.

### Convert anonymous user to identifiable user

If you don't have an customerUserId on instantiation, you can set it later at any time with the .identify() method. The most common cases are after registration, when a user switches from being an anonymous user (with a undefined customerUserId) to an authenticated user with some ID.

```Swift
Adapty.identify("YOUR_USER_ID") { (error) in
    if error == nil {
        // successful identify
    }
}
```

### Observer mode

In some cases, if you have already built a functioning subscription system, it may not be possible or feasible to use the Adapty SDK to make purchases. However, you can still use the SDK to get access to the data.

Just configure Adapty SDK in Observer Mode – update **`.activate`** method:

```Swift
Adapty.activate("PUBLIC_SDK_KEY", customerUserId: "YOUR_USER_ID", observerMode: true)
```

### Debugging

Adapty will log errors and other important information to help you understand what is going on. There are three levels available: **`verbose`**, **`errors`** and **`none`** in case you want a bit of a silence.
You can set this immediately in your app while testing, before you configure Adapty.

```Swift
Adapty.logLevel = .verbose
```

### Update your user

Later you might want to update your user.

```Swift
Adapty.updateProfile(email: "example@email.com",
                     phoneNumber: "+1-###-###-####",
                     facebookUserId: "###############",
                     amplitudeUserId: "###",
                     amplitudeDeviceId: "###",
                     mixpanelUserId: "###",
                     appmetricaProfileId: "###",
                     appmetricaDeviceId: "###",
                     firstName: "Test",
                     lastName: "Test",
                     gender: "",
                     birthday: Date) { (error) in
                        if error == nil {
                            // successful update                              
                        }
}
```

All properties are optional.  
For **`gender`** possible values are: **`m`**, **`f`**, but you can also pass custom string value.

### Attribution tracker integration

To integrate with attribution system, just pass attribution you receive to Adapty method.

```Swift
Adapty.updateAttribution("<attribution>", source: "<source>", networkUserId: "<networkUserId>") { (error) in
    if error == nil {
        // successful update
    }
}
```

**`attribution`** is `Dictionary` object.  
For **`source`** possible values are: **`.adjust`**, **`.appsflyer`**, **`.branch`**.  
**`networkUserId`** is `String?` object.

To integrate with [Adjust](https://www.adjust.com/), just pass attribution you receive from delegate method of Adjust iOS SDK.

```Swift
import Adjust

extension AppDelegate: AdjustDelegate {
    func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        if let attribution = attribution?.dictionary() {
            Adapty.updateAttribution(attribution, source: .adjust)
        }
    }
}
```

To integrate with [AppsFlyer](https://www.appsflyer.com/), just pass attribution you receive from delegate method of Adjust iOS SDK.

```Swift
import AppsFlyerLib

extension AppDelegate: AppsFlyerTrackerDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        // It's important to include the network user ID
        Adapty.updateAttribution(conversionInfo, source: .appsflyer, networkUserId: AppsFlyerTracker.shared().getAppsFlyerUID())
    }
}
```

[Branch](https://branch.io/) integration example.

To connect Branch user and Adapty user, make sure you provide your customerUserId as Branch Identity id.
If you prefer to not use customerUserId in Branch, user networkUserId param in attribution method to specify the Branch user ID to attach to.

```Swift
// login
Branch.getInstance().setIdentity("YOUR_USER_ID")

// logout
Branch.getInstance().logout()
```

Next, pass attribution you receive from initialize method of Branch iOS SDK to Adapty.

```Swift
import Branch

Branch.getInstance().initSession(launchOptions: launchOptions) { (data, error) in
    if let data = data {
        Adapty.updateAttribution(data, source: .branch)
    }
}
```

### Get purchase containers (paywalls)

```Swift
Adapty.getPurchaseContainers { (containers, products, state, error) in
    // if error is empty, containers should contain info about your paywalls, products contains info about all your products
}
```

For **`state`** possible values are: **`cached`**, **`synced`**. First means that data was taken from local cache, second means that data was updated from remote server.

### Make purchase

```Swift
Adapty.makePurchase(product: <product>, offerId: <offerId>) { (purchaserInfo, receipt, appleValidationResult, product, error) in
    if error == nil {
        // successful purchase
    }
    
    // response is a Dictionary, containing all info about receipt from AppStore
}
```

**`product`** is `ProductModel` object, it's required and can't be empty. You can get one from any available container. 
**`offerId`** is `String?` object, optional.
Adapty handles subscription offers signing for you as well.

### Restore purchases

```Swift
Adapty.restorePurchases { (error) in
    if error == nil {
        // successful restore
    }
}
```

### Validate your receipt

```Swift
Adapty.validateReceipt("<receiptEncoded>") { (response, error) in
    // response is a Dictionary, containing all info about receipt from AppStore
}
```

**`receiptEncoded`** is required and can't be empty.

### Get user purchases info

```Swift
Adapty.getPurchaserInfo { (purchaserInfo, state, error) in
    // purchaserInfo object contains all of the purchase and subscription data available about the user
}
```

For **`state`** possible values are: **`cached`**, **`synced`**. First means that data was taken from local cache, second means that data was updated from remote server. 
The **`purchaserInfo`** object gives you access to the following information about a user:

| Name  | Description |
| -------- | ------------- |
| paidAccessLevels | Dictionary where the keys are paid access level identifiers configured by developer in Adapty dashboard. Values are PaidAccessLevelsInfoModel objects. Can be null if the customer has no access levels. |
| subscriptions | Dictionary where the keys are vendor product ids. Values are SubscriptionsInfoModel objects. Can be null if the customer has no subscriptions. |
| nonSubscriptions | Dictionary where the keys are vendor product ids. Values are array[] of NonSubscriptionsInfoModel objects. Can be null if the customer has no purchases. |

**`paidAccessLevels`** stores info about current users access level.

| Name  | Description |
| -------- | ------------- |
| id | Paid Access Level identifier configured by developer in Adapty dashboard. |
| isActive | Boolean indicating whether the paid access level is active. |
| vendorProductId | Identifier of the product in vendor system (App Store/Google Play etc.) that unlocked this access level. |
| store | The store that unlocked this subscription, can be one of: **app_store**, **play_store** & **adapty**. |
| activatedAt | The ISO 8601 datetime when access level was activated (may be in the future). |
| renewedAt | The ISO 8601 datetime when access level was renewed. |
| expiresAt | The ISO 8601 datetime when access level will expire (may be in the past and may be null for lifetime access). |
| isLifetime | Boolean indicating whether the paid access level is active for lifetime (no expiration date). If set to true you shouldn't use **expires_at**. |
| activeIntroductoryOfferType | The type of active introductory offer. Possible values are: **free_trial**, **pay_as_you_go** & **pay_up_front**. If the value is not null it means that offer was applied during the current subscription period. |
| activePromotionalOfferType | The type of active promotional offer. Possible values are: **free_trial**, **pay_as_you_go** & **pay_up_front**. If the value is not null it means that offer was applied during the current subscription period. |
| willRenew | Boolean indicating whether auto renewable subscription is set to renew. |
| isInGracePeriod | Boolean indicating whether auto renewable subscription is in grace period. |
| unsubscribedAt | The ISO 8601 datetime when auto renewable subscription was cancelled. Subscription can still be active, it just means that auto renewal turned off. Will set to null if the user reactivates subscription. |
| billingIssueDetectedAt | The ISO 8601 datetime when billing issue was detected (vendor was not able to charge the card). Subscription can still be active. Will set to null if the charge was successful. |

**`subscriptions`** stores info about vendor subscription.

| Name  | Description |
| -------- | ------------- |
| isActive | Boolean indicating whether the subscription is active. |
| vendorProductId | Identifier of the product in vendor system (App Store/Google Play etc.). |
| store | Store where the product was purchased. Possible values are: **app_store**, **play_store** & **adapty**. |
| activatedAt | The ISO 8601 datetime when access level was activated (may be in the future). |
| renewedAt | The ISO 8601 datetime when access level was renewed. |
| expiresAt | The ISO 8601 datetime when access level will expire (may be in the past and may be null for lifetime access). |
| startsAt | The ISO 8601 datetime when access level stared. |
| isLifetime | Boolean indicating whether the subscription is active for lifetime (no expiration date). If set to true you shouldn't use **expires_at**. |
| activeIntroductoryOfferType | The type of active introductory offer. Possible values are: **free_trial**, **pay_as_you_go** & **pay_up_front**. If the value is not null it means that offer was applied during the current subscription period. |
| activePromotionalOfferType | The type of active promotional offer. Possible values are: **free_trial**, **pay_as_you_go** & **pay_up_front**. If the value is not null it means that offer was applied during the current subscription period. |
| willRenew | Boolean indicating whether auto renewable subscription is set to renew. |
| isInGracePeriod | Boolean indicating whether auto renewable subscription is in grace period. |
| unsubscribedAt | The ISO 8601 datetime when auto renewable subscription was cancelled. Subscription can still be active, it just means that auto renewal turned off. Will set to null if the user reactivates subscription. |
| billingIssueDetectedAt | The ISO 8601 datetime when billing issue was detected (vendor was not able to charge the card). Subscription can still be active. Will set to null if the charge was successful. |
| isSandbox | Boolean indicating whether the product was purchased in sandbox or production environment. |
| vendorTransactionId | Transaction id in vendor system. |
| vendorOriginalTransactionId | Original transaction id in vendor system. For auto renewable subscription this will be id of the first transaction in the subscription. |

**`nonSubscriptions `** stores info about purchases that are not subscriptions.

| Name  | Description |
| -------- | ------------- |
| purchaseId | Identifier of the purchase in Adapty. You can use it to ensure that you've already processed this purchase (for example tracking one time products). |
| vendorProductId | Identifier of the product in vendor system (App Store/Google Play etc.). |
| store | Store where the product was purchased. Possible values are: **app_store**, **play_store** & **adapty**. |
| purchasedAt | The ISO 8601 datetime when the product was purchased. |
| isOneTime | Boolean indicating whether the product should only be processed once. If true, the purchase will be returned by Adapty API one time only. |
| isSandbox | Boolean indicating whether the product was purchased in sandbox or production environment. |
| vendorTransactionId | Transaction id in vendor system. |
| vendorOriginalTransactionId | Original transaction id in vendor system. For auto renewable subscription this will be id of the first transaction in the subscription. |

### Checking if a user is subscribed 

The subscription status for a user can easily be determined from **`paidAccessLevels`** property of **`purchaserInfo`** object by **`isActive`** property inside.

```Swift
Adapty.getPurchaserInfo { (purchaserInfo, state, error) in
    if purchaserInfo?.paidAccessLevels["level_configured_in_dashboard"]?.isActive == true {
    
    }
}
```

### Listening for purchaser info updates

You can respond to any changes in purchaser info by conforming to an optional delegate method, didReceivePurchaserInfo. This will fire whenever we receive a change in purchaser info.

```Swift
extension AppDelegate: AdaptyDelegate {
    
    func didReceiveUpdatedPurchaserInfo(_ purchaserInfo: PurchaserInfoModel) {
        // handle any changes to purchaserInfo
    }
    
}
```

### Listening for promo container updates

You can respond to any changes in promo container by conforming to an optional delegate method, didReceivePromo. This will fire whenever we receive a change in promo container.

```Swift
extension AppDelegate: AdaptyDelegate {
    
    func didReceivePromo(_ promo: PromoModel) {
        // handle available promo
    }
    
}
```

### Manually get promo container

You can still trigger manual promo container update by calling method getPromo.

```Swift
Adapty.getPromo { (promo, error) in
    // promo object contains info about container with any promotional offer available 
}
```

### Handle Adapty push notifications

You can check and validate Adapty promo push notifications like this. This will allow us to handle such notifications and respond accordingly. 

```Swift
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    Adapty.handlePushNotification(userInfo) { (_) in
        completionHandler(UIBackgroundFetchResult.newData)
    }
}
```

### Custom paywalls

You can build your own paywall through the dashboard and show it inside the app with just one line of code.

```Swift
Adapty.showPaywall(for: container, from: controller, delegate: delegate)
```

**`container`** is **`PurchaseContainerModel`** object, related to your paywall.
**`controller`** is controller used to show a paywall controller.
**`delegate`** is someone who applies to **`AdaptyPaywallDelegate`** protocol.

To apply to **`AdaptyPaywallDelegate`** protocol implement such methods:

```Swift
extension ViewController: AdaptyPaywallDelegate {
    
    func didPurchase(product: ProductModel, purchaserInfo: PurchaserInfoModel?, receipt: String?, appleValidationResult: Parameters?, paywall: PaywallViewController) {
        // just call paywall.close() to close paywall if needed and do related calls you need
    }
    
    func didFailPurchase(product: ProductModel, error: Error, paywall: PaywallViewController) {
        // handle error
        
        // error can also be just a cancellation, to check that simply compare error with IAPManagerError.paymentWasCancelled 
        // (error as? IAPManagerError) == IAPManagerError.paymentWasCancelled
    }
    
    func didClose(paywall: PaywallViewController) {
        // paywall was closed by user without any purchases
    }
    
}
```

### Method swizzling in Adapty

The Adapty SDK performs method swizzling for receiving your APNs token. Developers who prefer not to use swizzling can disable it by adding the flag AdaptyAppDelegateProxyEnabled in the app’s Info.plist file and setting it to NO (boolean value).

If you have disabled method swizzling, you'll need to explicitly send your APNs to Adapty. Override the methods didRegisterForRemoteNotificationsWithDeviceToken to retrieve the APNs token, and then set Adapty's apnsToken property:

```Swift
func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    Adapty.apnsToken = deviceToken
}
```

### Logout user

Makes your user anonymous.

```Swift
Adapty.logout { (error) in
    if error == nil {
        // successful logout
    }
}
```

## License

Adapty is available under the MIT license. [See LICENSE](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/LICENSE) for details.
