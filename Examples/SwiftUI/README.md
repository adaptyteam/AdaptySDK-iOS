# Adapty-Demo app

This is a SwiftUI-based demo application for Adapty. Before running the app, you will need to configure the project.

### How to configure

Firstly, you will need to provide:
- the public key from your [Adapty Dashboard](https://app.adapty.io/home) 
- the identifer of a paywall you would like to display. 

You can also provide a [Remote Config](https://docs.adapty.io/docs/paywall#paywall-remote-config) for the paywall. 


##### Set Public SDK Key
In `AppDelegate.swift`, in the `application(_:didFinishLaunchingWithOptions:)` method you will find `Adapty.activate` method call with a placeholder – `YOUR_ADAPTY_APP_TOKEN`. You should replace it with your public key.
```swift
func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        Adapty.activate("YOUR_ADAPTY_APP_TOKEN", customerUserId: nil)
        ...
    }
```
To find it, go to [Adapty Dashboard](https://app.adapty.io/home), choose `App Settings` > `General`. There under the `API keys` section you will find your `Public SDK key`.
##### Provide Paywall ID
In `PaywallService.swift` there is a `getPaywalls` method, there is a predicate for a developerID inside it. The value is compared to `YOUR_PAYWALL_ID`. You should replace this placeholder with your paywall id.
```swift
func getPaywalls(completion: ((Error?) -> Void)? = nil) {
        reset()
    Adapty.getPaywall("YOUR_PAYWALL_ID") { [weak self] result in
        guard let self = self else { return }
        switch result {
        case let .success(paywall):
            self.paywall = paywall
            self.getPaywallProducts(for: paywall, completion: completion)
        case let .failure(error):
            completion?(error)
        }
    }
}
```
You can find the paywall ID on [Adapty Dashboard](https://app.adapty.io/home). Go to `Products & Paywalls`, choose `Paywalls` and find the corresponding `Paywall ID` in the table.

#### Remote Config
You can change the way the paywall is displayed on the fly using the [Remote Config](https://docs.adapty.io/docs/paywall#paywall-remote-config) tool. 

You can configure the following:
- description (the text under the icon) and its color
- text on the `Buy` button, its background and text colors
- background color of the paywall 
- icon (you can choose one of the local images); available image names are:
    - "Adapty-Diamonds"
    - "Adapty-Duck"
    - "Adapty-Face-with-Sunglasses"
    - "Adapty-Thinking-Face"


A sample JSON file looks like this:
```JSON
{
  "icon_name": "Adapty-Face-with-Sunglasses",
  "description": "Premium users help us earn more money!",
  "buy_button_text": "of premium for",
  "background_color": "#B575F7",
  "text_color": "#FFFFFF",
  "buy_button_style": {
    "button_color": "#FFFFFF",
    "button_text_color": "#B575F7"
  }
}
```
You can find the sample file (`sample_remote_config.json`) in the root directory of the project.
