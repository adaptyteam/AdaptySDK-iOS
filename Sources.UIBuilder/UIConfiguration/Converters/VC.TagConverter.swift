//
//  VC.TagConverter.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 21.04.2026.
//
import Foundation

protocol VCTagConverter {
    func toString(_: Any, locale: Locale) -> String?
}

extension VC.AnyConverter {
    var isTagConverter: Bool {
        wrapped is VCTagConverter
    }

    var asTagConverter: VCTagConverter? {
        wrapped as? VCTagConverter
    }
}
