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
