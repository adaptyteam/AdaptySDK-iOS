//
//  AdaptyUI+AssetsResolver.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 22.05.2025.
//

#if canImport(AVKit)

import AVKit
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
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

    private var resolved: Resolved {
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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension VC.ImageData {
    enum Resolved {
        case image(AdaptyPlatformImage?)
        case remote(URL, preview: AdaptyPlatformImage?)
    }

    func resolve(with resolver: AdaptyUIAssetsResolver) -> Resolved {
        guard let customId,
              case let .image(asset) = resolver.asset(for: customId),
              let resolved = asset.resolved
        else { return resolved }

        return resolved
    }

    fileprivate var resolved: Resolved {
        switch self {
        case let .raster(_, data):
            return .image(SystemSpecificAbstractionManager.image(from: data))
        case let .url(_, url, previewRaster: previewRaster):
            return .remote(url, preview: previewRaster.flatMap(SystemSpecificAbstractionManager.image(from:)))
        }
    }
}

extension VC.Font {
    typealias Resolved = AdaptyPlatformFont

    func resolve(with resolver: AdaptyUIAssetsResolver, withSize size: Double) -> Resolved {
        guard let customId,
              let asset = resolver.asset(for: customId)
        else { return resolved(withSize: size) }

        if let font = asset.platformResolvedFont {
            return font.withSize(size)
        }

        return resolved(withSize: size)
    }

    private func resolved(withSize size: Double) -> Resolved {
        AdaptyNativeFont.create(self, withSize: size)
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
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

    private var resolved: Resolved {
        switch self {
        case let .solidColor(color):
            return .solidColor(color.resolved)
        case let .colorGradient(gradient):
            return .colorGradient(gradient.resolved)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension VC.ColorGradient {
    typealias Resolved = AdaptyUICustomGradientAsset

    fileprivate var resolved: Resolved {
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
        items
            .map { Gradient.Stop(color: $0.color.resolved, location: $0.p) }
            .sorted(by: { $0.location < $1.location })
    }

    package var asCustomAsset: AdaptyUICustomAsset {
        .gradient(resolved)
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension VC.Color {
    typealias Resolved = SwiftUI.Color

    func resolve(with resolver: AdaptyUIAssetsResolver) -> Resolved {
        guard let customId,
              case let .color(asset) = resolver.asset(for: customId)
        else { return resolved }
        return asset.resolved
    }

    fileprivate var resolved: Resolved {
        SwiftUI.Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }

    package var asCustomAsset: AdaptyUICustomAsset {
        .color(.swiftUIColor(resolved))
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
private extension AdaptyUICustomVideoAsset {
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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
private extension AdaptyUICustomImageAsset {
    var resolved: VC.ImageData.Resolved? {
        switch self {
        case let .file(url):
            guard let data = try? Data(contentsOf: url),
                  let value = SystemSpecificAbstractionManager.image(from: data)
            else {
                return nil
            }
            return .image(value)
        default:
            break
        }

        if let remote = platformResolvedRemote {
            return .remote(remote.url, preview: remote.preview)
        }

        if let image = platformResolvedImage {
            return .image(image)
        }

        return nil
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
private extension AdaptyUICustomColorAsset {
    var resolved: VC.Color.Resolved {
        if let color = platformResolvedColor {
            return SystemSpecificAbstractionManager.swiftUIColor(from: color)
        }

        if case let .swiftUIColor(color) = self {
            return color
        }

        assertionFailure("Unsupported color asset case.")
        return .clear
    }
}

#endif
