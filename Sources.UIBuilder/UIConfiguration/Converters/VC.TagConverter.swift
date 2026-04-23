//
//  VC.TagConverter.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 21.04.2026.
//

extension VC {
    protocol TagConverter {
        func toString(_: Any) -> String?
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

