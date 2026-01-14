//
//  AdaptyUIAssetCache.swift
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

    var value: AdaptyUIResolvedAsset { customValue ?? stateValue }
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
final class AdaptyUIAssetCache {
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
        guard let assetId = ref?.getAssetId(state: state) else {
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

extension VC.Asset {
    static var defaultScreenBackground: Self {
        .solidColor(.black)
    }
}

@MainActor
extension AdaptyUIConfiguration.AssetReference {
    func getAssetId(state: AdaptyUIState) -> String? {
        switch self {
        case .assetId(let id):
            id
        case .variable(let variable):
            // TODO: think about fallback value?
            try? state.getValue(String.self, variable: variable)
        }
    }
}
