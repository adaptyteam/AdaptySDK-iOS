//
//  AdaptyUI+AssetsResolver.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 22.05.2025.
//

#if canImport(UIKit)

import Adapty
import AVKit
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension VC.VideoData {
    struct Resolved {
        let player: AVQueuePlayer
        let item: AVPlayerItem
        let image: VC.ImageData.Resolved?
    }

    func resolve(with resolver: AdaptyAssetsResolver) -> Resolved {
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
        case image(UIImage?)
        case remote(URL, preview: UIImage?)
    }

    func resolve(with resolver: AdaptyAssetsResolver) -> Resolved {
        guard let customId,
              case let .image(asset) = resolver.asset(for: customId),
              let resolved = asset.resolved
        else { return resolved }
        return resolved
    }

    fileprivate var resolved: Resolved {
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

    func resolve(with resolver: AdaptyAssetsResolver, withSize size: Double) -> Resolved {
        guard let customId,
              case let .font(value) = resolver.asset(for: customId)
        else { return resolved(withSize: size) }
        return value.withSize(size)
    }

    private func resolved(withSize size: Double) -> Resolved {
        UIFont.create(self, withSize: size)
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

    func resolve(with resolver: AdaptyAssetsResolver) -> Resolved {
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
    typealias Resolved = AdaptyCustomGradientAsset

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
        let result = items
            .map { Gradient.Stop(color: $0.color.resolved, location: $0.p) }
            .sorted(by: { $0.location < $1.location })

        return result
    }

    package var asCustomAsset: AdaptyCustomAsset {
        .gradient(resolved)
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension VC.Color {
    typealias Resolved = SwiftUI.Color

    func resolve(with resolver: AdaptyAssetsResolver) -> Resolved {
        guard let customId,
              case let .color(asset) = resolver.asset(for: customId)
        else { return resolved }
        return asset.resolved
    }

    fileprivate var resolved: Resolved {
        SwiftUI.Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }

    package var asCustomAsset: AdaptyCustomAsset {
        .color(.swiftUIColor(resolved))
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
private extension AdaptyCustomVideoAsset {
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
private extension AdaptyCustomImageAsset {
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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
private extension AdaptyCustomColorAsset {
    var resolved: VC.Color.Resolved {
        switch self {
        case let .uiColor(color):
            SwiftUI.Color(color)
        case let .swiftUIColor(color):
            color
        }
    }
}

#endif
