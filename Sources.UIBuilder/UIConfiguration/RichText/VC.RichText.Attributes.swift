//
//  VC.RichText.Attributes.swift
//  AdaptyUIBuild
//
//  Created by Aleksei Valiano on 01.12.2025.
//

import Foundation

package extension VC.RichText {
    struct Attributes: Sendable, Hashable {
        package let fontAssetId: VC.AssetIdentifier? // default?
        package let size: Double? // default?
        package let txtColor: VC.AssetIdentifierOrValue? // default?
        package let imageTintColor: VC.AssetIdentifierOrValue?
        package let background: VC.AssetIdentifierOrValue?
        package let strike: Bool? // default: false
        package let underline: Bool? // default: false
    }
}

extension VC.RichText.Attributes {
    var isEmpty: Bool {
        fontAssetId == nil
            && size == nil
            && txtColor == nil
            && imageTintColor == nil
            && background == nil
            && (strike ?? false) == false
            && (underline ?? false) == false
    }

    var nonEmptyOrNil: Self? { isEmpty ? nil : self }

    func apply(
        default other: VC.RichText.Attributes?
    ) -> Self {
        guard let other else { return self }
        return .init(
            fontAssetId: fontAssetId ?? other.fontAssetId,
            size: size ?? other.size,
            txtColor: txtColor ?? other.txtColor,
            imageTintColor: imageTintColor ?? other.imageTintColor,
            background: background ?? other.background,
            strike: strike ?? other.strike,
            underline: underline ?? other.underline
        )
    }
}



