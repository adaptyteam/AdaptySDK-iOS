//
//  VC.TextAttributes.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 08.02.2026.
//

import Foundation

extension VC {
    struct TextAttributes: Sendable, Hashable {
        let fontAssetId: VC.AssetReference? // default?
        let size: Double? // default?
        let txtColor: VC.AssetReference? // default?
        let imageTintColor: VC.AssetReference?
        let background: VC.AssetReference?
        let strike: Bool? // default: false
        let underline: Bool? // default: false
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
    }

    @inlinable
    var nonEmptyOrNil: Self? {
        isEmpty ? nil : self
    }
}
