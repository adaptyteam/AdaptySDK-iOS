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
Adapty.activate("YOUR_APP_KEY")
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
**`network`**
**`campaign`**
**`trackerToken`**
**`trackerName`**
**`adgroup`**
**`creative`**
**`clickLabel`**
**`adid`**

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
    // you can access info about specific purchase like this: purchaserInfo.paidAccessLevels["level_configured_in_dashboard"]?.isActive
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
