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

}
