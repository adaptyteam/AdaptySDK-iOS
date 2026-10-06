//
//  AdaptyUITagValueConverter.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 21.04.2026.
//

import Foundation

protocol AdaptyUITagValueConverter: Sendable {
    func toString(_: Any, locale: Locale) -> String?
}

