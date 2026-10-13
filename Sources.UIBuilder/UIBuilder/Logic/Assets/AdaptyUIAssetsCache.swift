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

    var asFontAsset: AdaptyUIResolvedFontAsset? {
        customValue?.asFontAsset ?? stateValue?.asFontAsset
    }

    var asVideoAsset: AdaptyUIResolvedVideoAsset? {
        customValue?.asVideoAsset ?? stateValue?.asVideoAsset
    }
}

@MainActor
final class AdaptyUIAssetsCache {
    private let stateHolder: AdaptyUIStateHolder
    private let customAssetsResolver: AdaptyUIAssetsResolver

    private var assetById: [String: AdaptyUICachedAsset] = [:]

    init(
        stateHolder: AdaptyUIStateHolder,
        customAssetsResolver: AdaptyUIAssetsResolver
    ) {
        self.stateHolder = stateHolder
        self.customAssetsResolver = customAssetsResolver
    }

    func resolveDataBinding(
        _ attr: VC.TextAttributes?,
        _ screen: VS.ScreenInstance
    ) -> VC.RichText.Attributes? {
        guard let attr else { return nil }
        return .init(
            fontAssetId: attr.fontAssetId?.getAssetIdentifier(state: stateHolder.current, screen: screen),
            size: attr.size,
            txtColor: attr.color?.getAssetId(state: stateHolder.current, screen: screen),
            imageTintColor: attr.imageTintColor?.getAssetId(state: stateHolder.current, screen: screen),
            background: attr.background?.getAssetId(state: stateHolder.current, screen: screen),
            strike: attr.strike,
            underline: attr.underline,
            letterSpacing: attr.letterSpacing
        ).nonEmptyOrNil
    }

    func cachedAsset(
        _ ref: AdaptyUIConfiguration.AssetReference?,
        mode: VC.Mode,
        screen: VS.ScreenInstance
    ) -> AdaptyUICachedAsset {
        guard let assetIdOrColor = ref?.getAssetId(
            state: stateHolder.current,
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

    /// Asset behind the reference in the public asset type, preferring the one
    /// supplied by the app over the one from the configuration.
    func asset(
        _ ref: AdaptyUIConfiguration.AssetReference?,
        mode: VC.Mode,
        screen: VS.ScreenInstance
    ) -> AdaptyUIAsset? {
        guard let assetIdOrColor = ref?.getAssetId(state: stateHolder.current, screen: screen) else { return nil }

        switch assetIdOrColor {
        case let .color(color):
            return .color(color.resolvedColor)
        case let .assetId(assetId):
            guard let stateAsset = try? stateHolder.current.asset(assetId, for: mode) else { return nil }

            if let customId = stateAsset.customId,
               let customAsset = customAssetsResolver.asset(for: customId)
            {
                return customAsset.asAsset
            }

            return stateAsset.asAsset
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

        guard let stateAsset = try? stateHolder.current.asset(assetId, for: mode) else {
            newAsset = .empty(mode: mode)
            return newAsset
        }

        let customAsset: AdaptyUIResolvedAsset? =
            if let customId = stateAsset.customId {
                customAssetsResolver.asset(for: customId)?.resolved(id: customId)
            } else {
                nil
            }

        newAsset = .init(
            customId: stateAsset.customId,
            mode: mode,
            stateValue: stateAsset.resolved(),
            customValue: customAsset
        )

        return newAsset
    }
}

@MainActor
extension AdaptyUIConfiguration.AssetReference {
    func getAssetIdentifier(
        state: AdaptyUIState,
        screen: VS.ScreenInstance
    ) -> VC.AssetIdentifier? {
        switch self {
        case .assetId(let id):
            id
        case .color:
            nil
        case .variable(let variable):
            try? state.getValue(
                VC.AssetIdentifier.self,
                variable: variable,
                screenInstance: screen
            )
        }
    }

    func getAssetId(
        state: AdaptyUIState,
        screen: VS.ScreenInstance
    ) -> VC.AssetIdentifierOrValue? {
        switch self {
        case .assetId(let id):
            .assetId(id)
        case .color(let color):
            .color(color)
        case .variable(let variable):
            try? state.getValue(
                VC.AssetIdentifierOrValue.self,
                variable: variable,
                screenInstance: screen
            )
        }
    }
}

#endif
