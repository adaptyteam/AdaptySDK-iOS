//
//  VC.Font.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

package extension VC {
    struct Font: CustomAsset, Sendable, Hashable {
        package let customId: String?
        package let alias: String
        package let familyName: String
        package let weight: Int
        package let italic: Bool
        let defaultSize: Double
        let defaultColor: Filling
    }
}

extension VC.Font {
    static let `default` = Self(
        customId: nil,
        alias: "adapty_system",
        familyName: "adapty_system",
        weight: 400,
        italic: false,
        defaultSize: 15,
        defaultColor: .solidColor(.black)
    )
}

#if DEBUG
package extension VC.Font {
    static func create(
        customId: String? = `default`.customId,
        alias: String = `default`.alias,
        familyName: String = `default`.familyName,
        weight: Int = `default`.weight,
        italic: Bool = `default`.italic,
        defaultSize: Double = `default`.defaultSize,
        defaultColor: VC.Filling = `default`.defaultColor
    ) -> Self {
        .init(
            customId: customId,
            alias: alias,
            familyName: familyName,
            weight: weight,
            italic: italic,
            defaultSize: defaultSize,
            defaultColor: defaultColor
        )
    }
}
#endif
