//
//  VC.RichText.Attributes.swift
//  AdaptyUIBuild
//
//  Created by Aleksei Valiano on 01.12.2025.
//

import Foundation

package extension VC.RichText {
    struct Attributes: Sendable, Hashable {
        package let font: VC.AssetReference? // default?
        package let size: Double? // default?
        package let txtColor: VC.AssetReference? // default?
        package let imageTintColor: VC.AssetReference?
        package let background: VC.AssetReference?
        package let strike: Bool? // default: false
        package let underline: Bool? // default: false
    }
}

extension VC.RichText.Attributes {
    var isEmpty: Bool {
        font == nil
            && size == nil
            && txtColor == nil
            && imageTintColor == nil
            && background == nil
            && (strike ?? false) == false
            && (underline ?? false) == false
    }

    var nonEmptyOrNil: Self? { isEmpty ? nil : self }
}


