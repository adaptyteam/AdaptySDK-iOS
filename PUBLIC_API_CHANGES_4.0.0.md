# Public API Changes for 4.0.0

## AdaptyUICustomVideoAsset

**Module:** AdaptyUIBuilder

**File:** `Sources.UIBuilder/UIBuilder/Logic/Assets/AdaptyUIAssetsResolver.swift`

**Change:** Every case gained a trailing `resolution: CGSize?` parameter so the host can declare the video's pixel size up-front. When provided, the player reserves layout space (aspect ratio = `width / height`) before the video loads.

Before:
```swift
case file(url: URL, preview: AdaptyUICustomImageAsset?)
case remote(url: URL, preview: AdaptyUICustomImageAsset?)
case player(item: AVPlayerItem, player: AVPlayer, preview: AdaptyUICustomImageAsset?)
```

After:
```swift
case file(url: URL, preview: AdaptyUICustomImageAsset?, resolution: CGSize?)
case remote(url: URL, preview: AdaptyUICustomImageAsset?, resolution: CGSize?)
case player(item: AVPlayerItem, player: AVPlayer, preview: AdaptyUICustomImageAsset?, resolution: CGSize?)
```

**Reason:** Mirrors the schema-side `v_res`/`h_res` properties on `Video` assets. Without resolution the player still expands to fill the available area as before.

**Migration:** Append `resolution: nil` (or pass the real `CGSize`) when constructing any `AdaptyUICustomVideoAsset` case.

---

**Change:** `.player` case now accepts `AVPlayer` instead of `AVQueuePlayer`.

Before:
```swift
case player(item: AVPlayerItem, player: AVQueuePlayer, preview: AdaptyUICustomImageAsset?)
```

After:
```swift
case player(item: AVPlayerItem, player: AVPlayer, preview: AdaptyUICustomImageAsset?)
```

**Reason:** Replaced `AVPlayerLooper`/`AVQueuePlayer`-based looping with a simpler `NotificationCenter` seek-based approach using plain `AVPlayer`. Fixes video playback issues on reopen.

**Migration:** Replace `AVQueuePlayer` with `AVPlayer` when constructing `.player(...)` cases.

## AdaptyUIResolvedFontAsset

**Module:** AdaptyUIBuilder

**File:** `Sources.UIBuilder/UIBuilder/Logic/Assets/AdaptyUIResolvedAsset.swift`

**Change:** `AdaptyUIResolvedFontAsset` changed from a typealias for `UIFont` to a struct.

Before:
```swift
typealias AdaptyUIResolvedFontAsset = UIFont
```

After:
```swift
struct AdaptyUIResolvedFontAsset {
    let font: UIFont
    let defaultColor: AdaptyUIResolvedColorAsset
    let defaultLetterSpacing: Double?
    let defaultLineHeight: Double?
}
```

**Reason:** Added support for `letter_spacing` and `line_height` font asset properties. The resolved font asset now carries these defaults alongside the `UIFont` and `defaultColor`.

**Migration:** Replace direct `UIFont` usage with `.font` property access (e.g. `fontAsset` → `fontAsset.font`).

## Rendering error callback renamed: `didFailRendering` → `didReceiveError`

**Module:** AdaptyUI, AdaptyUIBuilder, AdaptyPlugin

**Files:**
- `Sources.AdaptyUI/Paywalls/Rendering/AdaptyFlowView.swift`
- `Sources.AdaptyUI/Paywalls/Rendering/AdaptyFlowViewModifier.swift`
- `Sources.AdaptyUI/Paywalls/Rendering/AdaptyFlowViewDelegate.swift`
- `Sources.AdaptyUI/AdaptyUI+Public.swift` (`AdaptyUIDelegate`)
- `Sources.UIBuilder/UIBuilder/Public/AdaptyUIBuilder+FlowView.swift`
- `Sources.AdaptyPlugin/Events/FlowViewEvent.DidReceiveError.swift` (renamed from `FlowViewEvent.DidFailRendering.swift`)

**Change:** The callback/delegate method that reports errors from the paywall view has been renamed everywhere. It now also delivers runtime errors from the flow script (JavaScript exceptions) in addition to rendering errors — see the new `.jsException` case below.

Before:
```swift
// SwiftUI modifier / AdaptyFlowView init
.flow(
    flowConfiguration: ...,
    didFailRendering: { error in ... }
)

// AdaptyUIDelegate
func flowController(_ controller: AdaptyFlowController, didFailRenderingWith error: AdaptyUIError)

// AdaptyFlowViewDelegate
func flowView(_ view: AdaptyFlowUIView, didFailRenderingWith error: AdaptyUIError)
```

After:
```swift
.flow(
    flowConfiguration: ...,
    didReceiveError: { error in ... }
)

func flowController(_ controller: AdaptyFlowController, didReceiveError error: AdaptyUIError)

func flowView(_ view: AdaptyFlowUIView, didReceiveError error: AdaptyUIError)
```

**Reason:** The callback now also surfaces JavaScript runtime exceptions thrown by the paywall script, so the old name was misleading.

**Migration:** Replace every occurrence of `didFailRendering` / `didFailRenderingWith` with `didReceiveError` (callback labels, delegate method signatures, default implementations).

---

## `AdaptyUIError` / `AdaptyUIBuilderError`: new `.jsException` case

**Module:** AdaptyUI, AdaptyUIBuilder

**Files:**
- `Sources.AdaptyUI/Error/AdaptyUIError.swift`
- `Sources.UIBuilder/UIBuilder/Errors/AdaptyUIBuilderError.swift`

**Change:** Both error enums gained a `.jsException(String)` case (error code `4105` on `AdaptyUIError`), delivered through the renamed `didReceiveError` callback when the JS runtime throws.

Before:
```swift
public enum AdaptyUIError: Error {
    case platformNotSupported
    case adaptyNotActivated
    case adaptyUINotActivated
    case activateOnce
    case webKit(Error)
    case unsupportedTemplate(String)
    case wrongComponentType(String)
    case wrongAssetType(String)
}
```

After:
```swift
public enum AdaptyUIError: Error {
    case platformNotSupported
    case adaptyNotActivated
    case adaptyUINotActivated
    case activateOnce
    case webKit(Error)
    case unsupportedTemplate(String)
    case wrongComponentType(String)
    case wrongAssetType(String)
    case jsException(String)
}
```

**Reason:** The paywall runtime now forwards uncaught JavaScript exceptions to the host so they can be logged or surfaced to the user.

**Migration:** If you `switch` exhaustively over `AdaptyUIError` or `AdaptyUIBuilderError`, add a `.jsException` branch.

---

## Plugin wire event renamed: `flow_view_did_fail_rendering` → `flow_view_did_receive_error`

**Module:** AdaptyPlugin

**Files:**
- `Sources.AdaptyPlugin/Events/FlowViewEvent.DidReceiveError.swift` (renamed from `FlowViewEvent.DidFailRendering.swift`)
- `Sources.AdaptyPlugin/cross_platform.yaml`

**Change:** The crossplatform event struct `FlowViewEvent.DidFailRendering` was renamed to `FlowViewEvent.DidReceiveError` and its wire `id` constant `"flow_view_did_fail_rendering"` was renamed to `"flow_view_did_receive_error"`. The schema entry in `cross_platform.yaml` was updated accordingly.

**Reason:** Consistency with the renamed Swift callback and the broader error semantics (rendering + JS exceptions).

**Migration:** Update Flutter / React Native / Unity plugin consumers to listen for `flow_view_did_receive_error` instead of `flow_view_did_fail_rendering`.
