//
//  AdaptyUIAssetsCache.swift
//  Adapty
//
//  Created by Alex Goncharov on 14/01/2026.
//

#if canImport(UIKit)

import Foundation

struct AdaptyUICachedAsset {
    fileprivate let customId: String?
    fileprivate let mode: VC.Mode

    fileprivate let stateValue: AdaptyUIResolvedAsset?
    fileprivate let customValue: AdaptyUIResolvedAsset?
}

extension AdaptyUICachedAsset {
    static func empty(mode: VC.Mode) -> AdaptyUICachedAsset {
        .init(
            customId: nil,
            mode: mode,
            stateValue: nil,
            customValue: nil
        )
    }

    var asColorAsset: AdaptyUIResolvedColorAsset? {
        customValue?.asColorAsset ?? stateValue?.asColorAsset
    }

    var asImageAsset: AdaptyUIResolvedImageAsset? {
        customValue?.asImageAsset ?? stateValue?.asImageAsset
    }

    var asColorOrGradientAsset: AdaptyUIResolvedColorOrGradientAsset? {
        customValue?.asColorOrGradientAsset ?? stateValue?.asColorOrGradientAsset
    }

    var asColorOrGradientOrImageAsset: AdaptyUIResolvedColorOrGradientOrImageAsset? {
        customValue?.asColorOrGradientOrImageAsset ?? stateValue?.asColorOrGradientOrImageAsset
    }

    var asFontAsset: (font: AdaptyUIResolvedFontAsset, defaultColor: AdaptyUIResolvedColorAsset)? {
        customValue?.asFontAsset ?? stateValue?.asFontAsset
    }

    var asVideoAsset: AdaptyUIResolvedVideoAsset? {
        customValue?.asVideoAsset ?? stateValue?.asVideoAsset
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

    func resolveDataBinding(
        _ attr: VC.Text.Attributes?,
        _ screen: VS.ScreenInstance
    ) -> VC.RichText.Attributes? {
        guard let attr else { return nil }
        return .init(
            fontAssetId: attr.fontAssetId,
            size: attr.size,
            txtColor: attr.txtColor?.getAssetId(state: state, screen: screen),
            imageTintColor: attr.imageTintColor?.getAssetId(state: state, screen: screen),
            background: attr.background?.getAssetId(state: state, screen: screen),
            strike: attr.strike,
            underline: attr.underline
        ).nonEmptyOrNil
    }

    func cachedAsset(
        _ ref: AdaptyUIConfiguration.AssetReference?,
        mode: VC.Mode,
        screen: VS.ScreenInstance
    ) -> AdaptyUICachedAsset {
        guard let assetIdOrColor = ref?.getAssetId(
            state: state,
            screen: screen
        ) else {
            return .empty(mode: mode)
        }

        return cachedAsset(assetIdOrColor, mode: mode)
    }

    func cachedAsset(
        _ assetIdOrColor: AdaptyUIConfiguration.AssetIdentifierOrValue?,
        mode: VC.Mode
    ) -> AdaptyUICachedAsset {
        guard let assetIdOrColor else {
            return .empty(mode: mode)
        }

        switch assetIdOrColor {
        case .assetId(let assetId):
            return cachedAsset(assetId, mode: mode)
        case .color(let color):
            return .init(
                customId: nil,
                mode: mode,
                stateValue: .color(color.resolvedColor),
                customValue: nil
            )
        }
    }

    func cachedAsset(
        _ assetId: AdaptyUIConfiguration.AssetIdentifier?,
        mode: VC.Mode
    ) -> AdaptyUICachedAsset {
        guard let assetId else {
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
    func getAssetId(
        state: AdaptyUIState,
        screen: VS.ScreenInstance
    ) -> VC.AssetIdentifierOrValue? {
        switch self {
        case .assetId(let id):
            return .assetId(id)
        case .color(let color):
            return .color(color)
        case .variable(let variable):
            return try? state.getValue(
                VC.AssetIdentifierOrValue.self,
                variable: variable,
                screenInstance: screen
            )
        }
    }
}

#endif
