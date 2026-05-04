//
//  VC.TagConverter.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 21.04.2026.
//
import Foundation

extension VC {
    protocol TagConverter {
        func toString(_: Any, locale: Locale) -> String?
    }
}

extension VC.AnyConverter {
    var isTagConverter: Bool {
        wrapped is VC.TagConverter
    }

    var asTagConverter: VC.TagConverter? {
        wrapped as? VC.TagConverter
    }
}

