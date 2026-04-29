//
//  VC.Font.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

extension VC {
    struct Font: Sendable, Equatable {
        let customId: String?
        let alias: String
        let familyName: String
        let weight: Int
        let italic: Bool
        let defaultSize: Double
        let defaultColor: Color

        let defaultLetterSpacing: Double?
        let defaultLineHeight: Double?
    }
}
