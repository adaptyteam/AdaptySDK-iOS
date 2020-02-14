# Adapty iOS SDK

[![Version](https://img.shields.io/cocoapods/v/Adapty.svg?style=flat)](https://cocoapods.org/pods/Adapty)
[![License](https://img.shields.io/cocoapods/l/Adapty.svg?style=flat)](https://cocoapods.org/pods/Adapty)
[![Platform](https://img.shields.io/cocoapods/p/Adapty.svg?style=flat)](https://cocoapods.org/pods/Adapty)

![Adapty: Win back churned subscribers in your iOS app](https://raw.githubusercontent.com/adaptyteam/AdaptySDK-iOS/master/adapty.png)

Adapty helps you track business metrics, and lets you run ad campaigns targeted at churned users faster, written in Swift. https://adapty.io/

## Requirements

- iOS 12.0+
- Xcode 10.2+
- Swift 5+

## Installation

### CocoaPods

1. Create a Podfile if you don't have one: `pod init`
2. Add Adapty to your Podfile: `pod 'Adapty', '~> 1.0.0'`
3. Save the file and run: `pod install`. This creates an `.xcworkspace` file for your app. Use this file for all future development on your application.

## Usage

### Configure your app

In your AppDelegate class:

```Swift
import Adapty
```

And add the following to `application(_:didFinishLaunchingWithOptions:)`:

```Swift
Adapty.activate("YOUR_APP_KEY", customerUserId: "YOUR_USER_ID")
```

If your app doesn't have user IDs, you can use **`.activate("YOUR_APP_KEY")`** or pass nil for the **`customerUserId`**. Anyway, you can update **`customerUserId`** later within user update request.

### Observer Mode

In some cases, if you have already built a functioning subscription system, it may not be possible or feasible to use the Adapty SDK to make purchases. However, you can still use the SDK to get access to the data.

Just configure Adapty SDK in Observer Mode – update **`.activate`** method:

```Swift
Adapty.activate("YOUR_APP_KEY", customerUserId: "YOUR_USER_ID", observerMode: true)
```

### Update your user

Later you might want to update your user.

```Swift
Adapty.updateProfile(customerUserId: "<id-in-your-system>",
                     email: "example@email.com",
                     phoneNumber: "+1-###-###-####",
                     facebookUserId: "###############",
                     amplitudeUserId: "###",
                     mixpanelUserId: "###",
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
Adapty.updateAttribution("<attribution>") { (error) in
    if error == nil {
        // successful update
    }
}
```

**`attribution`** is `Dictionary?` object.

Supported keys in **`attribution`** are the following:
```
network
campaign
trackerToken
trackerName
adgroup
creative
clickLabel
adid
```

To integrate with [AdjustSDK](https://github.com/adjust/ios_sdk), just pass attribution you receive from delegate method of Adjust iOS SDK `- (void)adjustAttributionChanged:(ADJAttribution *)attribution` to Adapty `updateAttribution` method.

### Get purchase containers (paywalls)

```Swift
Adapty.getPurchaseContainers { (containers, error) in
    // if error is empty, containers should contain info about your paywalls
}
```

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
Adapty.getPurchaserInfo { (purchaserInfo, error) in
    // purchaserInfo object contains all of the purchase and subscription data available about the user
}
```

The **`purchaserInfo`** object gives you access to the following information about a user:

| Name  | Description |
| -------- | ------------- |
| promotionalOfferEligibility | Property which shows if user is eligible for introductory offer for App Store/Play Store. |
| introductoryOfferEligibility | Property which shows if user is eligible for promotional offer for App Store/Play Store. |
| paidAccessLevels | Dicionary, where keys – paid levels identifiers, configured in admin panel, values – PaidAccessLevelsInfoModel objects. |
| subscriptions | Dicionary, where keys – vendor products identifiers, values – SubscriptionsInfoModel objects. |
| nonSubscriptions | Dicionary, where keys – vendor products identifiers, values – array of NonSubscriptionsInfoModel objects. |
| appleValidationResult | Info received from Apple receipt validation. |

**`paidAccessLevels`** stores info about current users access level.

| Name  | Description |
| -------- | ------------- |
| id | Id of paid level access. |
| isActive | Whether or not the user has access to this level. |
| vendorProductId | The underlying product identifier that unlocked this level. |
| store | The store that unlocked this subscription, can be one of: app_store, play_store & adapty. |
| activatedAt | The first date this product was purchased. |
| renewedAt | The date of the last renewal. |
| expiresAt | The expiration date for the subscription, can be null for lifetime access. |
| isLifetime | This property says if subscription is infinite, which means it doesn't have an expiration date. |
| activeIntroductoryOfferType | Type of active intro offer, can be one of: free_trial, pay_as_you_go & pay_up_front. If it's not null, that means it's active for now. |
| activePromotionalOfferType | Type of active promo offer, can be one of: free_trial, pay_as_you_go & pay_up_front. If it's not null, that means it's active for now. |
| willRenew | Whether or not the subscription is set to renew at the end of the current period. |
| isInGracePeriod | If subscription is under grace period. |
| unsubscribedAt | The date an unsubscribe was detected. An unsubscribe does not mean that the level is inactive. Note there may be a multiple hour delay between the value of this property and the actual state in the App Store / Play Store. |
| billingIssueDetectedAt | The date a billing issue was detected, will be null again once billing issue resolved. A billing issue does not mean that the entitlement is inactive. Note there may be a multiple hour delay between the value of this property and the actual state in the App Store / Play Store. |

**`subscriptions`** stores info about vendor subscription.

| Name  | Description |
| -------- | ------------- |
| isActive | description |
| vendorProductId | description |
| store | description |
| activatedAt | description |
| renewedAt | description |
| expiresAt | description |
| isLifetime | description |
| activeIntroductoryOfferType | description |
| activePromotionalOfferType | description |
| willRenew | description |
| isInGracePeriod | description |
| unsubscribedAt | description |
| billingIssueDetectedAt | description |
| isSandbox | description |
| vendorTransactionId | description |
| vendorOriginalTransactionId | description |

**`nonSubscriptions `** stores info about purchases that are not subscriptions.

| Name  | Description |
| -------- | ------------- |
| purchaseId | description |
| vendorProductId | description |
| store | description |
| purchasedAt | description |
| isOneTime | description |
| isSandbox | description |
| vendorTransactionId | description |
| vendorOriginalTransactionId | description |

### Checking if a user is subscribed 

The subscription status for a user can easily be determined from **`paidAccessLevels`** property of **`purchaserInfo`** object by **`isActive`** property inside.

```Swift
Adapty.getPurchaserInfo { (purchaserInfo, error) in
    if purchaserInfo?.paidAccessLevels["level_configured_in_dashboard"]?.isActive == true {
    
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

## License

Adapty is available under the GNU license. [See LICENSE](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/LICENSE) for details.
