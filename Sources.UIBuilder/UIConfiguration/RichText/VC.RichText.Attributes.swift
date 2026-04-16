//
//  VC.RichText.Attributes.swift
//  AdaptyUIBuild
//
//  Created by Aleksei Valiano on 01.12.2025.
//

import Foundation

extension VC.RichText {
    struct Attributes: Sendable, Hashable {
        let fontAssetId: VC.AssetIdentifier? // default?
        let size: Double? // default?
        let txtColor: VC.AssetIdentifierOrValue? // default?
        let imageTintColor: VC.AssetIdentifierOrValue?
        let background: VC.AssetIdentifierOrValue?
        let strike: Bool? // default: false
        let underline: Bool? // default: false
        let letterSpacing: Double?
    }
}

extension VC.RichText.Attributes {
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
    }

    @inlinable
    var nonEmptyOrNil: Self? {
        isEmpty ? nil : self
    }

    @inlinable
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
            underline: underline ?? other.underline,
            letterSpacing: letterSpacing ?? other.letterSpacing
        )
    }


    

//
//    return .init(
//        fontAssetId: attr.fontAssetId?.getAssetIdentifier(state: state, screen: screen),
//        size: attr.size,
//        txtColor: attr.txtColor?.getAssetId(state: state, screen: screen),
//        imageTintColor: attr.imageTintColor?.getAssetId(state: state, screen: screen),
//        background: attr.background?.getAssetId(state: state, screen: screen),
//        strike: attr.strike,
//        underline: attr.underline
//    ).nonEmptyOrNil
}

