//
//  VC.RichText.Item.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.12.2025.
//

import Foundation

package extension VC.RichText {
    enum Item: Sendable, Hashable {
        case text(String, Attributes?)
        case tag(String, Attributes?)
        case image(VC.AssetReference, Attributes?)
        case unknown
    }
}
