//
//  VC+Asset.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 30.06.2023
//

import Foundation

@available(*, deprecated, renamed: "test", message: "test")
package extension VC {
    enum Filling: Sendable, Hashable {
        case solidColor(Color)
        case colorGradient(ColorGradient)

        var asSolidColor: VC.Color? {
            switch self {
            case let .solidColor(value): value
            default: nil
            }
        }

        var asColorGradient: VC.ColorGradient? {
            switch self {
            case let .colorGradient(value): value
            default: nil
            }
        }
    }
}

@available(*, deprecated, renamed: "test", message: "test")
extension VC.Asset {
    @inlinable
    var asFilling: VC.Filling? {
        switch self {
        case let .solidColor(value):
            .solidColor(value)
        case let .colorGradient(value):
            .colorGradient(value)
        default:
            nil
        }
    }

    @inlinable
    var asColor: VC.Color? {
        guard case let .solidColor(value) = self else {
            return nil
        }
        return value
    }

    var asColorGradient: VC.ColorGradient? {
        guard case let .colorGradient(value) = self else {
            return nil
        }
        return value
    }

    @inlinable
    var asImageData: VC.ImageData? {
        guard case let .image(value) = self else {
            return nil
        }
        return value
    }

    @inlinable
    var asVideoData: VC.VideoData? {
        guard case let .video(value) = self else {
            return nil
        }
        return value
    }

    @inlinable
    var asFont: VC.Font? {
        guard case let .font(value) = self else {
            return nil
        }
        return value
    }
}
