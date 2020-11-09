* [Observer mode](#observer-mode)
* [Convert anonymous user to identifiable user](#convert-anonymous-user-to-identifiable-user)
* [Logout user](#logout-user)
* [Attribution tracker integration](#attribution-tracker-integration)
  + [Adjust integration](#adjust-integration)
  + [AppsFlyer integration](#appsflyer-integration)
  + [Branch integration](#branch-integration)
* [Update your user attributes](#update-your-user-attributes)
* [Displaying products](#displaying-products)
  + [Get paywalls](#get-paywalls)
  + [Custom dashboard paywalls](#custom-dashboard-paywalls)
  + [Fallback paywalls](#fallback-paywalls)
* [Working with purchases](#working-with-purchases)
  + [Making purchases](#making-purchases)
  + [Restoring purchases](#restoring-purchases)
  + [Receipt validation](#receipt-validation)
  + [Making deferred purchases](#making-deferred-purchases)
* [Subscription status](#subscription-status)
  + [Getting user purchases info](#getting-user-purchases-info)
  + [Checking if a user is subscribed](#checking-if-a-user-is-subscribed)
  + [Listening for purchaser info updates](#listening-for-purchaser-info-updates)
* [Promo campaigns](#promo-campaigns)
  + [Listening for promo paywall updates](#listening-for-promo-paywall-updates)
  + [Getting promo paywall manually](#getting-promo-paywall-manually)
  + [Handle Adapty promo push notifications](#handle-adapty-promo-push-notifications)
* [Method swizzling in Adapty](#method-swizzling-in-adapty)
* [SwiftUI](#swiftui)
  + [SwiftUI App Lifecycle](#swiftui-app-lifecycle)
  + [Custom dashboard paywalls with SwiftUI](#custom-dashboard-paywalls-with-swiftui)

# Advanced usage

## Observer mode

In some cases, if you have already built a functioning subscription system, it may not be possible or feasible to use the Adapty SDK to make purchases. However, you can still use the SDK to get access to the data.

Just configure Adapty SDK in Observer Mode – update **`.activate`** method:

```Swift
Adapty.activate("PUBLIC_SDK_KEY", customerUserId: "YOUR_USER_ID", observerMode: true)
```

## Convert anonymous user to identifiable user

If you don't have an customerUserId on instantiation, you can set it later at any time with the .identify() method. The most common cases are after registration, when a user switches from being an anonymous user (with a undefined customerUserId) to an authenticated user with some ID.

```Swift
Adapty.identify("YOUR_USER_ID") { (error) in
    if error == nil {
        // successful identify
    }
}
```

## Logout user

Makes your user anonymous.

```Swift
Adapty.logout { (error) in
    if error == nil {
        // successful logout
    }
}
```

## Attribution tracker integration

Adapty has support for most popular attribution systems which allows you to track how much revenue was driven by each source and ad network.  
To integrate with attribution system, just pass attribution you receive to Adapty method.

```Swift
Adapty.updateAttribution("<attribution>", source: "<source>", networkUserId: "<networkUserId>") { (error) in
    if error == nil {
        // successful update
    }
}
```

**`attribution`** is a `Dictionary` object.  
For **`source`** possible values are: **`.adjust`**, **`.appsflyer`**, **`.branch`** and **`.custom`**.  
**`networkUserId`** is a `String?` object.

### Adjust integration 

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

### AppsFlyer integration

To integrate with [AppsFlyer](https://www.appsflyer.com/), just pass attribution you receive from delegate method of AppsFlyer iOS SDK.

```Swift
import AppsFlyerLib

// AppsFlyer v5 (AppsFlyerTrackerDelegate)
extension AppDelegate: AppsFlyerTrackerDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        // It's important to include the network user ID
        Adapty.updateAttribution(conversionInfo, source: .appsflyer, networkUserId: AppsFlyerTracker.shared().getAppsFlyerUID())
    }
}

// AppsFlyer v6 (AppsFlyerLibDelegate)
extension AppDelegate: AppsFlyerLibDelegate {
    func onConversionDataSuccess(_ installData: [AnyHashable : Any]) {
        // It's important to include the network user ID
        Adapty.updateAttribution(installData, source: .appsflyer, networkUserId: AppsFlyerLib.shared().getAppsFlyerUID())
    }
}
```

### Branch integration

[Branch](https://branch.io/) integration example.

To connect Branch user and Adapty user, make sure you provide your customerUserId as Branch Identity id.
If you prefer to not use customerUserId in Branch, user networkUserId param in attribution method to specify the Branch user ID to attach to.

```Swift
// login
Branch.getInstance().setIdentity("YOUR_USER_ID")

// logout
Branch.getInstance().logout()
```

Next, pass the attribution you receive from initialize method of Branch iOS SDK to Adapty.

```Swift
import Branch

Branch.getInstance().initSession(launchOptions: launchOptions) { (data, error) in
    if let data = data {
        Adapty.updateAttribution(data, source: .branch)
    }
}
```

### Apple Search Ads

The AdaptySDK can automatically collect Apple Search Ad attribution data. All you need is to add `AdaptyAppleSearchAdsAttributionCollectionEnabled` in the app’s Info.plist file and set it to `YES` (boolean value).

## Update your user attributes

You can add optional information to your user, such as email, phone number, etc. or update it with analytics ids to make tracking even more precise.

```Swift
let params = ProfileParameterBuilder().withEmail("example@email.com").withPhoneNumber("+1-###-###-####")...with<Key>(<value>)
Adapty.updateProfile(params: params) { (error) in
    if error == nil {
        // successful update                              
    }
}
```

Possible keys `.<key>` and their possible values described below:

| Key  | Possible value |
| -------- | ------------- |
| email | String |
| phoneNumber | String |
| facebookUserId | String |
| amplitudeUserId | String |
| amplitudeDeviceId | String |
| mixpanelUserId | String |
| appmetricaProfileId | String|
| appmetricaDeviceId | String |
| firstName | String |
| lastName | String |
| gender | enum Gender, possible values are: **`female`**, **`male`** and **`other`** |
| birthday | Date |
| customAttributes | Dictionary |
| appTrackingTransparencyStatus | UInt, [app tracking transparency status](https://developer.apple.com/documentation/apptrackingtransparency/attrackingmanager/authorizationstatus/) you can receive starting from iOS 14. To receive it just call `let status = ATTrackingManager.AuthorizationStatus` – you should send this specific property to Adapty as soon as it changes, after you request it from user `Adapty.updateProfile(params: ProfileParameterBuilder().withAppTrackingTransparencyStatus(status.rawValue))`  |

## Displaying products

### Get paywalls

Paywalls are fetched through the SDK based on their configuration in the Adapty dashboard.  
As soon as you get your paywalls info, you can build your own.

```Swift
Adapty.getPaywalls { (paywalls, products, state, error) in

}
```

**`paywalls`** is an array of [`PaywallModel`](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/Documentation/Models.md#paywallmodel) objects, containing info about your paywalls.  
**`products`** is an array [`ProductModel`](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/Documentation/Models.md#productmodel) objects, containing info about all your products.  
For **`state`** possible values are: **`cached`**, **`synced`**. First means that data was taken from a local cache, second means that data was updated from a remote server.

### Custom dashboard paywalls

You can build your own paywall through the dashboard and show it inside the app with just one line of code.

```Swift
Adapty.showPaywall(for: paywall, from: controller, delegate: delegate)
```

**`paywall`** is a [`PaywallModel`](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/Documentation/Models.md#paywallmodel) object, related to your paywall.  
**`controller`** is a controller used to show a paywall controller.  
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

You can also get your `PaywallViewController` to present it in a way you want.

```Swift
let paywallViewController = Adapty.getPaywall(for: paywall, delegate: delegate)
```

### Fallback paywalls

In case you have an imported dashboard JSON file with your paywalls, you can provide it to SDK as a fallback scenario for user.  
So if Adapty backend will be offline for some unexpected reason, you can still show user paywall and operate through it. You can later get it later through [Get paywalls](#get-paywalls) method.

```Swift
if let path = Bundle.main.path(forResource: "fallback_paywalls", ofType: "json"), let paywalls = try? String(contentsOfFile: path, encoding: .utf8) {
    // you can get paywalls string in any other way as well
    Adapty.setFallbackPaywalls(paywalls)
}
```

**`paywalls`** is a string representation of your paywalls JSON list. 

## Working with purchases

### Making purchases

To make a purchase, pass product you received from [your paywall](#get-paywalls) to `.makePurchase()` method.

```Swift
Adapty.makePurchase(product: <product>, offerId: <offerId>) { (purchaserInfo, receipt, appleValidationResult, product, error) in
    if error == nil {
        // successful purchase
    }
}
```

**`product`** is a [`ProductModel`](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/Documentation/Models.md#productmodel) object, it's required and can't be empty. You can get one from any available paywall.  
**`offerId`** is a `String?` object, optional.
Adapty handles subscription offers signing for you as well.

**`purchaserInfo`** is a [`PurchaserInfoModel?`](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/Documentation/Models.md#purchaserinfomodel) object, containing information about user and his payment status.  
**`receipt`** is a `String?` representation of the Apple's receipt.  
**`appleValidationResult`** is a `Dictionary?` object, containing data, returned by Apple's receipt validation services.  
**`product`** is a [`ProductModel?`](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/Documentation/Models.md#productmodel) object you've passed to this method.

### Restoring purchases

You can restore user's purchases and if there is some, it will appear in her [purchases info](#subscription-status).

```Swift
Adapty.restorePurchases { (purchaserInfo, receipt, appleValidationResult, error) in
    if error == nil {
        // successful restore
    }
}
```

### Receipt validation

You can also validate your receipt through SDK without any backend implementation on your side. 

```Swift
Adapty.validateReceipt("<receiptEncoded>") { (purchaserInfo, response, error) in
    if error == nil {
        // successful validation
    }
}
```

**`receiptEncoded`** is required and can't be empty.

**`purchaserInfo`** is a [`PurchaserInfoModel?`](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/Documentation/Models.md#purchaserinfomodel) object, containing information about user and his payment status.  
**`response`** is a `Dictionary?`, containing all info about receipt from AppStore.

### Making deferred purchases

For deferred purchases Adapty SDK has an optional delegate method, which is called when the user starts an in-app purchase in the App Store, and the transaction continues in your app.    
Just store **`makeDeferredPurchase`** and call it later if you want to hold your purchase for now and show paywall to your user first as said in Apple's guidelines.    
If you want to continue purchase, call **`makeDeferredPurchase`** at the same moment you got it.

```Swift
extension AppDelegate: AdaptyDelegate {

    func paymentQueue(shouldAddStorePaymentFor product: ProductModel, defermentCompletion makeDeferredPurchase: @escaping DeferredPurchaseCompletion) {
        // you can store makeDeferredPurchase callback and call it later as well
        
        // or you can call it right away
        makeDeferredPurchase { (purchaserInfo, receipt, response, product, error) in
            // check your purchase
        }
    }
    
}
```

## Subscription status

### Getting user purchases info

It's super easy to fetch user purchases info – there is a one-liner for this: 

```Swift
Adapty.getPurchaserInfo { (purchaserInfo, state, error) in

}
```

**`purchaserInfo`** is a [`PurchaserInfoModel?`](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/Documentation/Models.md#purchaserinfomodel) object, containing information about user and his payment status.  
For **`state`** possible values are: **`cached`**, **`synced`**. First means that data was taken from a local cache, second means that data was updated from a remote server. 

### Checking if a user is subscribed 

The subscription status for a user can easily be determined from **`accessLevels`** property of **`purchaserInfo`** object by **`isActive`** property inside.

```Swift
Adapty.getPurchaserInfo { (purchaserInfo, state, error) in
    if purchaserInfo?.accessLevels["level_configured_in_dashboard"]?.isActive == true {
    
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

**`purchaserInfo`** is a [`PurchaserInfoModel?`](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/Documentation/Models.md#purchaserinfomodel) object, containing information about user and his payment status.

## Promo campaigns

Promo Campaigns designed for upselling and win back lapsed customers in your app. Send promo offers with automated campaigns in push notifications.

### Listening for promo paywall updates

You can respond to any changes in the promo paywall by conforming to an optional delegate method, didReceivePromo. This will fire whenever we receive a change in the promo paywall.

```Swift
extension AppDelegate: AdaptyDelegate {
    
    func didReceivePromo(_ promo: PromoModel) {
        // handle available promo
    }
    
}
```

**`promo`** is a [`PromoModel`](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/Documentation/Models.md#promomodel) object, containing information about available promotional (if so) offer for current user.

### Getting promo paywall manually

You can still trigger manual promo paywall update by calling method getPromo.

```Swift
Adapty.getPromo { (promo, error) in

}
```

**`promo`** is a [`PromoModel`](https://github.com/adaptyteam/AdaptySDK-iOS/blob/master/Documentation/Models.md#promomodel) object, containing information about available promotional (if so) offer for current user.

### Handle Adapty promo push notifications

You can check and validate Adapty promo push notifications like this. This will allow us to handle such notifications and respond accordingly. 

```Swift
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    Adapty.handlePushNotification(userInfo) { (_) in
        completionHandler(UIBackgroundFetchResult.newData)
    }
}
```

## Method swizzling in Adapty

The Adapty SDK performs method swizzling for receiving your APNs token. Developers who prefer not to use swizzling can disable it by adding the flag `AdaptyAppDelegateProxyEnabled` in the app’s Info.plist file and setting it to `NO` (boolean value).

If you have disabled method swizzling, you'll need to explicitly send your APNs to Adapty. Override the methods `didRegisterForRemoteNotificationsWithDeviceToken` to retrieve the APNs token, and then set Adapty's `apnsToken` property:

```Swift
func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    Adapty.apnsToken = deviceToken
}
```

## SwiftUI 

### SwiftUI App Lifecycle

Since Xcode 12 and new SwiftUI, app can be created without AppDelegate at all.

So you can put your configuration code inside `init` method.

```Swift
import Adapty

@main
struct SwiftUISampleApp: App {
    init() {
        Adapty.activate("PUBLIC_SDK_KEY", customerUserId: "YOUR_USER_ID")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

Or you can still do it through AppDelegate, but it requires you to create your own `@UIApplicationDelegateAdaptor`.

```Swift
import Adapty

@main
struct SwiftUISampleApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Adapty.activate("PUBLIC_SDK_KEY", customerUserId: "YOUR_USER_ID")
        return true
    }
}
```

### Custom dashboard paywalls with SwiftUI

It can be complicated how to present `PaywallViewController` via SwiftUI. Here is an example of a very basic implementation.

```Swift
import SwiftUI
import Adapty

struct SwiftUISampleView: View {
    @ObservedObject var subscriptionInteractor = SubscriptionInteractor()
    
    var body: some View {
        Text("Sample")
            // bind "isPresented" property and present our controller when needed
            .fullScreenCover(isPresented: $subscriptionInteractor.isPresented) {
                PaywallViewControllerRepresentation(paywallModel: subscriptionInteractor.paywall!, delegate: subscriptionInteractor)
            }
    }
}

class SubscriptionInteractor: ObservableObject {
    var paywall: PaywallModel? = nil
    @Published var isPresented = false
    
    init() {
        Adapty.getPaywalls { (paywalls, products, state, error) in
            if state == .synced, let paywall = paywalls?.first {
                // receive needed synced paywall
                self.paywall = paywall
                self.isPresented = true
            }
        }
    }
}

extension SubscriptionInteractor: AdaptyPaywallDelegate { ... }

struct PaywallViewControllerRepresentation: UIViewControllerRepresentable {
    let paywallModel: PaywallModel
    let delegate: AdaptyPaywallDelegate
    
    // wrapper over our controller for SwiftUI
    func makeUIViewController(context: Context) -> PaywallViewController {
        return Adapty.getPaywall(for: paywallModel, delegate: delegate)
    }
    
    func updateUIViewController(_ uiViewController: PaywallViewController, context: Context) { }
}
```
