import SwiftUI

@MainActor
package struct RemoteImage<Placeholder: View>: View {
    private let url: URL
    private let placeholder: () -> Placeholder
    private let onSuccess: (@MainActor (MediaCacheHit) -> Void)?
    private let onFailure: (@MainActor (Error) -> Void)?
    private var isResizable: Bool = false

    package init(
        url: URL,
        @ViewBuilder placeholder: @escaping () -> Placeholder,
        onSuccess: (@MainActor (MediaCacheHit) -> Void)? = nil,
        onFailure: (@MainActor (Error) -> Void)? = nil
    ) {
        self.url = url
        self.placeholder = placeholder
        self.onSuccess = onSuccess
        self.onFailure = onFailure
    }

    package func resizable() -> Self {
        var copy = self
        copy.isResizable = true
        return copy
    }

    package var body: some View {
        let image = KFImage
            .url(url)
            .targetCache(MediaCache.cache)
            .onSuccess { result in
                onSuccess?(MediaCacheHit(result.cacheType))
            }
            .onFailure { error in
                onFailure?(error)
            }
            .placeholder { placeholder() }

        if isResizable {
            image.resizable()
        } else {
            image
        }
    }
}
