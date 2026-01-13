//
//  AdaptyUI+AssetsResolver.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 22.05.2025.
//

#if canImport(UIKit)

import AVKit
import SwiftUI

extension VC.VideoData {
    struct Resolved {
        let player: AVQueuePlayer
        let item: AVPlayerItem
        let image: VC.ImageData.Resolved?
    }

    func resolve(with resolver: AdaptyUIAssetsResolver) -> Resolved {
        guard let customId,
              case let .video(asset) = resolver.asset(for: customId)
        else { return resolved }
        return asset.resolved
    }

    var resolved: Resolved {
        let item = AVPlayerItem(url: url)
        let player = AVQueuePlayer(items: [item])
        player.isMuted = true

        return Resolved(
            player: player,
            item: item,
            image: image.resolved
        )
    }
}

extension VC.ImageData {
    enum Resolved {
        case image(UIImage?)
        case remote(URL, preview: UIImage?)
    }

    func resolve(with resolver: AdaptyUIAssetsResolver) -> Resolved {
        guard let customId,
              case let .image(asset) = resolver.asset(for: customId),
              let resolved = asset.resolved
        else { return resolved }
        return resolved
    }

    var resolved: Resolved {
        switch self {
        case let .raster(_, data):
            return .image(UIImage(data: data))
        case let .url(_, url, previewRaster: previewRaster):
            return .remote(url, preview: previewRaster.flatMap(UIImage.init))
        }
    }
}

extension VC.Font {
    typealias Resolved = UIFont

    func resolve(with resolver: AdaptyUIAssetsResolver, withSize size: Double) -> Resolved {
        guard let customId,
              case let .font(value) = resolver.asset(for: customId)
        else { return resolved(withSize: size) }
        return value.withSize(size)
    }

    func resolved(withSize size: Double) -> Resolved {
        UIFont.create(self, withSize: size)
    }
}

extension VC.Filling {
    enum Resolved {
        case solidColor(VC.Color.Resolved)
        case colorGradient(VC.ColorGradient.Resolved)
    }

    private var customId: String? {
        switch self {
        case let .solidColor(color):
            color.customId
        case let .colorGradient(gradient):
            gradient.customId
        }
    }

    func resolve(with resolver: AdaptyUIAssetsResolver) -> Resolved {
        guard let customId,
              let asset = resolver.asset(for: customId)
        else { return resolved }

        switch asset {
        case let .color(asset):
            return .solidColor(asset.resolved)
        case let .gradient(asset):
            return .colorGradient(asset)
        default:
            return resolved
        }
    }

    var resolved: Resolved {
        switch self {
        case let .solidColor(color):
            return .solidColor(color.resolved)
        case let .colorGradient(gradient):
            return .colorGradient(gradient.resolved)
        }
    }
}

extension VC.ColorGradient {
    typealias Resolved = AdaptyUICustomGradientAsset

    var resolved: Resolved {
        switch kind {
        case .linear: .linear(
                gradient: .init(stops: stops),
                startPoint: start.unitPoint,
                endPoint: end.unitPoint
            )
        case .conic: .angular(
                gradient: .init(stops: stops),
                center: .center,
                angle: .degrees(360)
            )
        case .radial: .radial(
                gradient: .init(stops: stops),
                center: .center,
                startRadius: 0.0,
                endRadius: 1.0
            )
        }
    }

    private var stops: [Gradient.Stop] {
        let result = items
            .map { Gradient.Stop(color: $0.color.resolved, location: $0.p) }
            .sorted(by: { $0.location < $1.location })

        return result
    }

    package var asCustomAsset: AdaptyUICustomAsset {
        .gradient(resolved)
    }
}

extension VC.Color {
    typealias Resolved = SwiftUI.Color

    func resolve(
        with resolver: AdaptyUIAssetsResolver,
        stateViewModel: AdaptyUIStateViewModel
    ) -> Resolved {
        guard let customId,
              case let .color(asset) = resolver.asset(for: customId)
        else { return resolved }
        return asset.resolved
    }

    var resolved: Resolved {
        SwiftUI.Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }

    package var asCustomAsset: AdaptyUICustomAsset {
        .color(.swiftUIColor(resolved))
    }
}

@MainActor
extension VC.AssetReference {
    func resolveSolidColor(
        with resolver: AdaptyUIAssetsResolver,
        stateViewModel: AdaptyUIStateViewModel,
        mode: VC.Mode
    ) -> SwiftUI.Color? {
        guard let asset = stateViewModel.asset(
            self,
            mode: mode,
            defaultValue: nil
        ) else {
            return nil
        }

        if let customId = asset.customId,
           let customAsset = resolver.asset(for: customId),
           case let .color(customAssetColor) = customAsset
        {
            return customAssetColor.resolved
        }

        guard case let .solidColor(color) = asset else {
            // TODO: warning
            return nil
        }

        return color.resolved
    }
}

extension AdaptyUICustomVideoAsset {
    var resolved: VC.VideoData.Resolved {
        switch self {
        case let .file(url, preview),
             let .remote(url, preview):
            let playerItem = AVPlayerItem(url: url)
            let queuePlayer = AVQueuePlayer(items: [playerItem])
            queuePlayer.isMuted = true
            return .init(player: queuePlayer, item: playerItem, image: preview.flatMap { $0.resolved })
        case let .player(item, player, preview):
            return .init(player: player, item: item, image: preview.flatMap { $0.resolved })
        }
    }
}

extension AdaptyUICustomImageAsset {
    var resolved: VC.ImageData.Resolved? {
        switch self {
        case let .file(url):
            guard let data = try? Data(contentsOf: url), let value = UIImage(data: data) else { return nil }
            return .image(value)
        case let .remote(url, preview):
            return .remote(url, preview: preview)
        case let .uiImage(value):
            return .image(value)
        }
    }
}

extension AdaptyUICustomColorAsset {
    var resolved: VC.Color.Resolved {
        switch self {
        case let .uiColor(color):
            SwiftUI.Color(color)
        case let .swiftUIColor(color):
            color
        }
    }
}

// extension AdaptyUICustomGradientAsset {
//    var resolved: VC.ColorGradient.Resolved {
//        switch self {
//        case .linear(let gradient, let startPoint, let endPoint):
//            <#code#>
//        case .angular(let gradient, let center, let angle):
//            <#code#>
//        case .radial(let gradient, let center, let startRadius, let endRadius):
//            <#code#>
//        }
//
//        switch self {
//        case let .uiColor(color):
//            SwiftUI.Color(color)
//        case let .swiftUIColor(color):
//            color
//        }
//    }
// }

#endif
