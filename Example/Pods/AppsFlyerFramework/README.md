<img src="https://www.appsflyer.com/wp-content/uploads/2016/11/logo-1.svg"  width="450">

# AppsFlyerFramework

[![Version](https://img.shields.io/cocoapods/v/AppsFlyerFramework.svg?style=flat)](http://cocoapods.org/pods/AppsFlyerFramework)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Table of contents
- [Introduction](#introduction)
- [Requirements](#requirements)
- [Installation](#installation)
- [Integration AppsFlyer](#integration-appsflyer)
- [Changelog](#changelog)

## Introduction
[AppsFlyer](https://www.appsflyer.com/) helps mobile marketers measure and improve their performance through amazing tools, really big data and over 2,000 integrations.


In order for us to provide optimal support, we would kindly ask you to submit any issues to support@appsflyer.com

**When submitting an issue please specify your AppsFlyer sign-up(account) email, your app ID, production steps, logs, code snippets and any additional relevant information**

## Requirements
- iOS 8.0+ / macOS 10.11+ / tvOS 9.0+

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate AppsFlyer into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'AppsFlyerFramework'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. 

To integrate AppsFlyerFramework `5.1.0` version or higher for `Carthage` into your Xcode project, specify it in your `Cartfile`:

```ogdl
binary "https://raw.githubusercontent.com/AppsFlyerSDK/AppsFlyerFramework/master/AppsFlyerLib.json"
```
Starting from the version `5.1.0` and higher, **AppsFlyerLib.framework** is a **static** framework. In order to successfully integrate it, please follow next steps: 

- In your project settings `General -> Frameworks, Libraries and Embedded Content`  add `AppsFlyerLib.framework` and set `Do not embed` option for it;
- Make sure you remove and do not add any static frameworks as input/output files for `/usr/local/bin/carthage copy-frameworks` **Run script**.

In order to integrate AppsFlyerFramework version `5.0.0` and lower, specify following contents in your `Cartfile`:

```ogdl
binary "https://raw.githubusercontent.com/AppsFlyerSDK/AppsFlyerFramework/master/AppsFlyerTracker.json"
```

- Add **AppsFlyerTracker.framework** file to `General -> Frameworks, Libraries and Embedded Content`;
- Make sure to add AppsFlyerFramework Build path as input file for `/usr/local/bin/carthage copy-frameworks` **Run script**.

## Integration AppsFlyer

### Basic iOS integration

1. Add `pod 'AppsFlyerFramework' in Podfile
2. Run `pod update`
3. Implement in ```AppDelegate```:
```swift
import AppsFlyerLib

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        AppsFlyerTracker.shared().isDebug = true
        AppsFlyerTracker.shared().appsFlyerDevKey = "devkey";
        AppsFlyerTracker.shared().appleAppID = "1234567890"
        AppsFlyerTracker.shared().delegate = self
    }
}

func applicationDidBecomeActive(_ application: UIApplication) {        
        AppsFlyerTracker.shared().trackAppLaunch()
}
```
4. Implement delegates:
```swift
extension AppDelegate: AppsFlyerTrackerDelegate {
    func onConversionDataSuccess(_ conversionInfo: [String : Any]) {
        print(conversionInfo)
    }
    
    func onConversionDataFail(_ error: Error) {
        print(error)
    }
    
    func onAppOpenAttribution(_ attributionData: [String : Any]) {
        print(attributionData)
    }
    
    func onAppOpenAttributionFailure(_ error: Error) {
        print(error)
    }
}    
```

### Basic macOS integration(*BETA*)

1. Add `pod 'AppsFlyerFramework', '5.1.0'` in Podfile
2. Run `pod update`
3. Implement in ```AppDelegate```:
```swift
import AppsFlyerAttribution

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        AppsFlyerTracker.shared().isDebug = true
        AppsFlyerTracker.shared().appsFlyerDevKey = "devkey";
        AppsFlyerTracker.shared().appleAppID = "1234567890"
        AppsFlyerTracker.shared().delegate = self
        AppsFlyerTracker.shared().trackAppLaunch()
    }
}    
```
**Note:** AppsFlyerTracker setup *must* be in `-applicationWillFinishLaunching:` and not in `-applicationDidFinishLaunching:`

**Note:** `-trackAppLaunch` call in `-applicationWillFinishLaunching:`

4. Implement delegates:
```swift
extension AppDelegate: AppsFlyerTrackerDelegate {
    func onConversionDataSuccess(_ conversionInfo: [String : Any]) {
        print(conversionInfo)
    }
    
    func onConversionDataFail(_ error: Error) {
        print(error)
    }
    
    func onAppOpenAttribution(_ attributionData: [String : Any]) {
        print(attributionData)
    }
    
    func onAppOpenAttributionFailure(_ error: Error) {
        print(error)
    }
}    
```

## Changelog
------------

You can find the release changelog [here](https://support.appsflyer.com/hc/en-us/articles/115001224823-AppsFlyer-iOS-SDK-Release-Notes).

---

----------
