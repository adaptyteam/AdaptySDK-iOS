//
//  VC.RichText.Attributes.swift
//  AdaptyUIBuild
//
//  Created by Aleksei Valiano on 01.12.2025.
//

import Foundation

package extension VC.RichText {
    struct Attributes: Sendable, Hashable {
        package let font: VC.Font
        package let size: Double
        package let txtColor: VC.Mode<VC.Filling>
        package let imageTintColor: VC.Mode<VC.Filling>?
        package let background: VC.Mode<VC.Filling>?
        package let strike: Bool
        package let underline: Bool
    }
}
