//
//  VC.TextAttributes.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 08.02.2026.
//

import Foundation

extension VC {
    struct TextAttributes: Sendable {
        let fontAssetId: VC.AssetReference? // default?
        let size: Double? // default?
        let txtColor: VC.AssetReference? // default?
        let imageTintColor: VC.AssetReference?
        let background: VC.AssetReference?
        let strike: Bool? // default: false
        let underline: Bool? // default: false
        let letterSpacing: Double?
        let lineHeight: Double?
    }
}

extension VC.TextAttributes {
    @inlinable
    var isEmpty: Bool {
        fontAssetId == nil
            && size == nil
            && txtColor == nil
            && imageTintColor == nil
            && background == nil
            && (strike ?? false) == false
            && (underline ?? false) == false
            && letterSpacing == nil
            && lineHeight == nil
    }

    @inlinable
    var nonEmptyOrNil: Self? {
        isEmpty ? nil : self
    }

    @inlinable
    func apply(
        overide: VC.RichText.Attributes?
    ) -> Self {
        guard let overide else { return self }
        var fontAssetId = fontAssetId
        if let value = overide.fontAssetId {
            fontAssetId = .assetId(value)
        }
        return VC.TextAttributes(
            fontAssetId: fontAssetId,
            size: overide.size ?? size,
            txtColor: overide.txtColor?.asAssetReference ?? txtColor,
            imageTintColor: overide.imageTintColor?.asAssetReference ?? imageTintColor,
            background: overide.background?.asAssetReference ?? background,
            strike: overide.strike ?? strike,
            underline: overide.underline ?? underline,
            letterSpacing: overide.letterSpacing ?? letterSpacing,
            lineHeight: lineHeight
        )
    }
}

