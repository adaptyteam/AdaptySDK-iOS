//
//  VC.Variable.MapConvertor.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 13.04.2026.
//

import Foundation

extension VC.Variable {
    struct MapConvertor: Converter {
        var name: String {
            "Map"
        }

        let values: [VC.AnyValue]
    }
}

