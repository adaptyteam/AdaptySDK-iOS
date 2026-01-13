//
//  VS+Assets.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 07.01.2026.
//

import Foundation

extension VS {
    @inlinable
    func asset(_ assetId: String, for mode: VC.Mode) throws(VS.Error) -> VC.Asset {
        guard let value = assetOrNil(assetId, for: mode) else {
            throw .notFoundAsset(assetId)
        }
        return value
    }

    private func assetOrNil(_ assetId: String, for mode: VC.Mode) -> VC.Asset? {
        if let suffix = mode.suffix, let value = configuration.assets[assetId + suffix] {
            return value
        }

        return configuration.assets[assetId]
    }

//    private func id(from assetReference: VC.AssetReference) throws(VS.Error) -> String {
//        guard case let .assetId(assetId) = assetReference else {
//            throw .referenceWithoutAssetId
//        }
//        return assetId
//    }
//
//    @inlinable
//    func background(assetReference: VC.AssetReference, for mode: VC.Mode) throws(VS.Error) -> VC.Background {
//        let assetId = try id(from: assetReference)
//        return switch try asset(assetId, for: mode) {
//        case let .filling(value):
//            .filling(value)
//        case let .image(value):
//            .image(value)
//        default:
//            throw .wrongTypeAsset("Asset \(assetId + (mode.suffix ?? "")) must be color, any-gradient, or image")
//        }
//    }
//
//    @inlinable
//    func filling(assetReference: VC.AssetReference, for mode: VC.Mode) throws(VS.Error) -> VC.Filling {
//        let assetId = try id(from: assetReference)
//        let asset = try asset(assetId, for: mode)
//        guard case let .filling(value) = asset else {
//            throw VS.Error.wrongTypeAsset("Asset \(assetId + (mode.suffix ?? "")) must be color or any-gradient")
//        }
//        return value
//    }
//
//    @inlinable
//    func color(assetReference: VC.AssetReference, for mode: VC.Mode) throws(VS.Error) -> VC.Color {
//        let assetId = try id(from: assetReference)
//        let asset = try asset(assetId, for: mode)
//        guard case let .filling(.solidColor(value)) = asset else {
//            throw VS.Error.wrongTypeAsset("Asset \(assetId + (mode.suffix ?? "")) must be color")
//        }
//        return value
//    }
//
//    @inlinable
//    func imageData(assetReference: VC.AssetReference, for mode: VC.Mode) throws(VS.Error) -> VC.ImageData {
//        let assetId = try id(from: assetReference)
//        let asset = try asset(assetId, for: mode)
//        guard case let .image(value) = asset else {
//            throw VS.Error.wrongTypeAsset("Asset \(assetId + (mode.suffix ?? "")) must be image")
//        }
//        return value
//    }
//
//    @inlinable
//    func videoData(assetReference: VC.AssetReference, for mode: VC.Mode) throws(VS.Error) -> VC.VideoData {
//        let assetId = try id(from: assetReference)
//        let asset = try asset(assetId, for: mode)
//        guard case let .video(value) = asset else {
//            throw VS.Error.wrongTypeAsset("Asset \(assetId + (mode.suffix ?? "")) must be video")
//        }
//        return value
//    }
//
//    @inlinable
//    func font(assetReference: VC.AssetReference, for mode: VC.Mode) throws(VS.Error) -> VC.Font {
//        let assetId = try id(from: assetReference)
//        let asset = try asset(assetId, for: mode)
//        guard case let .font(value) = asset else {
//            throw VS.Error.wrongTypeAsset("Asset \(assetId + (mode.suffix ?? "")) must be font")
//        }
//        return value
//    }
}
