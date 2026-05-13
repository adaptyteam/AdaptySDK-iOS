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
