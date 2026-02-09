//
//  VC.Text.Attributes.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 08.02.2026.
//

import Foundation

package extension VC.Text {
    struct Attributes: Sendable, Hashable {
        package let fontAssetId: VC.AssetIdentifier? // default?
        package let size: Double? // default?
        package let txtColor: VC.AssetReference? // default?
        package let imageTintColor: VC.AssetReference?
        package let background: VC.AssetReference?
        package let strike: Bool? // default: false
        package let underline: Bool? // default: false
    }
}

extension VC.Text.Attributes {
    var isEmpty: Bool {
        fontAssetId == nil
            && size == nil
            && txtColor == nil
            && imageTintColor == nil
            && background == nil
            && (strike ?? false) == false
            && (underline ?? false) == false
    }

    var nonEmptyOrNil: Self? {
        isEmpty ? nil : self
    }
}
