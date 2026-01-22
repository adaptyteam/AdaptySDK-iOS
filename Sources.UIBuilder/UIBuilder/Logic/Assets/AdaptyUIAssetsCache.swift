//
//  AdaptyUIAssetsCache.swift
//  Adapty
//
//  Created by Alex Goncharov on 14/01/2026.
//

import Foundation

struct AdaptyUICachedAsset {
    fileprivate let customId: String?
    fileprivate let mode: VC.Mode

    fileprivate let stateValue: AdaptyUIResolvedAsset
    fileprivate let customValue: AdaptyUIResolvedAsset?

    // TODO: x refactor this asset consumption logic
    // first try to convert custom asset to expected
    // then try to convert state asset to expected
    var value: AdaptyUIResolvedAsset {
        if let customValue, !customValue.isNothing {
            customValue
        } else {
            stateValue
        }
    }
}

extension AdaptyUICachedAsset {
    static func empty(mode: VC.Mode) -> AdaptyUICachedAsset {
        .init(
            customId: nil,
            mode: mode,
            stateValue: .nothing,
            customValue: nil
        )
    }
}

@MainActor
final class AdaptyUIAssetsCache {
    private let state: AdaptyUIState
    private let customAssetsResolver: AdaptyUIAssetsResolver

    private var assetById: [String: AdaptyUICachedAsset] = [:]

    init(
        state: AdaptyUIState,
        customAssetsResolver: AdaptyUIAssetsResolver
    ) {
        self.state = state
        self.customAssetsResolver = customAssetsResolver
    }

    func cachedAsset(
        _ ref: AdaptyUIConfiguration.AssetReference?,
        mode: VC.Mode
    ) -> AdaptyUICachedAsset {
        guard let assetIdOrColor = ref?.getAssetId(state: state) else {
            return .empty(mode: mode)
        }

        guard case .assetId(let assetId) = assetIdOrColor else {
            // TODO: assetIdOrColor has color case, we dont need use cache for this asset
            return .empty(mode: mode)
        }

        if let chachedAsset = assetById[assetId], chachedAsset.mode == mode {
            return chachedAsset
        }

        var newAsset: AdaptyUICachedAsset

        defer {
            assetById[assetId] = newAsset
        }

        guard let stateAsset = try? state.asset(assetId, for: mode) else {
            newAsset = .empty(mode: mode)
            return newAsset
        }

        let customAsset: AdaptyUICustomAsset? =
            if let customId = stateAsset.customId {
                customAssetsResolver.asset(for: customId)
            } else {
                nil
            }

        newAsset = .init(
            customId: stateAsset.customId,
            mode: mode,
            stateValue: stateAsset.resolved(),
            customValue: customAsset?.resolved()
        )

        return newAsset
    }
}

@MainActor
extension AdaptyUIConfiguration.AssetReference {
    func getAssetId(state: AdaptyUIState) -> VC.AssetIdentifierOrValue? {
        switch self {
        case .assetId(let id): .assetId(id)
        case .color(let color): .color(color)
        case .variable(let variable):
            try? state.getValue(VC.AssetIdentifierOrValue.self, variable: variable)
        }
    }
}
