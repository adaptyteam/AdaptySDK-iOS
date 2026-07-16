//
//  AdaptyLottie.swift
//  AdaptyLottie
//
//  Proof of concept: default Lottie renderer addon. Depends on the Lottie SPM package;
//  this is the only target that links Lottie.
//

#if canImport(UIKit)

import AdaptyUIBuilder
import Lottie
import SwiftUI

public struct AdaptyLottie: AdaptyUILottieAddon {
    public init() {}

    @MainActor
    public func makeView(context: AdaptyUILottieContext) -> AnyView {
        let id = context.animationId
        let contentMode = context.fit.contentMode

        var view = LottieView { () async throws -> LottieAnimationSource? in
            await Self.resolve(id)
        }
        // `resizable` lets the view take the offered frame; `contentMode` then decides
        // how the animation scales inside it. Both are needed for `fit` to mean anything.
        .resizable()
        .configure { $0.contentMode = contentMode }
        .animationSpeed(context.speed)
        // Text overrides by keypath (AE layer name). An empty dictionary keeps the authored text.
        .textProvider(DictionaryTextProvider(context.texts))

        view = context.autoplay
            ? view.playing(loopMode: context.loop.lottieLoopMode)
            : view.paused()

        // Color overrides by keypath, e.g. "Text 1.Color" / "Shape.Fill 1.Color".
        for (keypath, hex) in context.colors {
            guard let color = Self.lottieColor(hex: hex) else { continue }
            view = view.valueProvider(
                ColorValueProvider(color),
                for: AnimationKeypath(keypath: keypath)
            )
        }

        return AnyView(view)
    }

    /// Parses "#RRGGBB" / "#RRGGBBAA" (alpha defaults to FF).
    private static func lottieColor(hex: String) -> LottieColor? {
        var string = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        if string.count == 6 { string += "FF" }
        guard string.count == 8, let value = UInt32(string, radix: 16) else { return nil }
        return LottieColor(
            r: Double((value >> 24) & 0xFF) / 255,
            g: Double((value >> 16) & 0xFF) / 255,
            b: Double((value >> 8) & 0xFF) / 255,
            a: Double(value & 0xFF) / 255
        )
    }

    /// Resolves `animationId` against the host bundle. An explicit extension picks the format —
    /// needed when both `<name>.lottie` and `<name>.json` are bundled under the same base name.
    /// Without an extension we probe dotLottie first, then Lottie JSON.
    private static func resolve(_ id: String) async -> LottieAnimationSource? {
        if id.hasSuffix(".lottie") {
            return await dotLottie(String(id.dropLast(".lottie".count)))
        }
        if id.hasSuffix(".json") {
            return json(String(id.dropLast(".json".count)))
        }
        if let dotLottie = await dotLottie(id) {
            return dotLottie
        }
        return json(id)
    }

    private static func dotLottie(_ name: String) async -> LottieAnimationSource? {
        guard let file = try? await DotLottieFile.named(name) else { return nil }
        return .dotLottieFile(file)
    }

    private static func json(_ name: String) -> LottieAnimationSource? {
        guard let animation = LottieAnimation.named(name) else { return nil }
        return .lottieAnimation(animation)
    }
}

private extension AdaptyUILottieLoop {
    var lottieLoopMode: LottieLoopMode {
        switch self {
        case .once: .playOnce
        case .loop: .loop
        case .pingPong: .autoReverse
        }
    }
}

private extension AdaptyUILottieFit {
    var contentMode: UIView.ContentMode {
        switch self {
        case .fit: .scaleAspectFit
        case .fill: .scaleAspectFill
        case .stretch: .scaleToFill
        }
    }
}

#endif
