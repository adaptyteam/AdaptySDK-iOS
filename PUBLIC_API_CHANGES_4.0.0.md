# Public API Changes for 4.0.0

## AdaptyUICustomVideoAsset

**Module:** AdaptyUIBuilder

**File:** `Sources.UIBuilder/UIBuilder/Logic/Assets/AdaptyUIAssetsResolver.swift`

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
